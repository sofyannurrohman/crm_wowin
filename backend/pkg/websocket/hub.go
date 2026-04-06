package websocket

import (
	"encoding/json"
	"log"
	"net/http"
	"sync"

	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true // Allow all origins for simplicity, in prod apply strict check
	},
}

// Hub maintains the set of active clients
type Hub struct {
	clients    map[string]map[*websocket.Conn]bool // user_id -> connections
	broadcast  chan Message
	register   chan *Client
	unregister chan *Client
	mu         sync.RWMutex
}

type Message struct {
	UserID  string      `json:"user_id"`
	Payload interface{} `json:"payload"`
}

type Client struct {
	Hub    *Hub
	Conn   *websocket.Conn
	UserID string
}

var DefaultHub *Hub

func init() {
	DefaultHub = NewHub()
	go DefaultHub.Run()
}

func NewHub() *Hub {
	return &Hub{
		clients:    make(map[string]map[*websocket.Conn]bool),
		broadcast:  make(chan Message),
		register:   make(chan *Client),
		unregister: make(chan *Client),
	}
}

func (h *Hub) Run() {
	for {
		select {
		case client := <-h.register:
			h.mu.Lock()
			if _, ok := h.clients[client.UserID]; !ok {
				h.clients[client.UserID] = make(map[*websocket.Conn]bool)
			}
			h.clients[client.UserID][client.Conn] = true
			h.mu.Unlock()

		case client := <-h.unregister:
			h.mu.Lock()
			if conns, ok := h.clients[client.UserID]; ok {
				if _, ok := conns[client.Conn]; ok {
					delete(conns, client.Conn)
					client.Conn.Close()
					if len(conns) == 0 {
						delete(h.clients, client.UserID)
					}
				}
			}
			h.mu.Unlock()

		case message := <-h.broadcast:
			h.mu.RLock()
			conns, ok := h.clients[message.UserID]
			h.mu.RUnlock()

			if ok {
				msgBytes, err := json.Marshal(message.Payload)
				if err == nil {
					h.mu.Lock()
					for conn := range conns {
						err := conn.WriteMessage(websocket.TextMessage, msgBytes)
						if err != nil {
							conn.Close()
							delete(conns, conn)
						}
					}
					if len(conns) == 0 {
						delete(h.clients, message.UserID)
					}
					h.mu.Unlock()
				}
			}
		}
	}
}

// PushNotification exposes a safe way to push to a user
func (h *Hub) PushNotification(userID string, payload interface{}) {
	h.broadcast <- Message{
		UserID:  userID,
		Payload: payload,
	}
}

// ServeWs handles websocket requests from the peer.
func (h *Hub) ServeWs(w http.ResponseWriter, r *http.Request, userID string) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Println("upgrade error:", err)
		return
	}
	client := &Client{Hub: h, Conn: conn, UserID: userID}
	client.Hub.register <- client

	go func() {
		defer func() {
			client.Hub.unregister <- client
		}()
		for {
			_, _, err := conn.ReadMessage()
			if err != nil {
				if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
					log.Printf("error: %v", err)
				}
				break
			}
		}
	}()
}
