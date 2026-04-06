package handlers

import (
	"crm_wowin_backend/internal/usecase"
	"crm_wowin_backend/pkg/response"
	"crm_wowin_backend/pkg/websocket"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type NotificationHandler struct {
	uc usecase.NotificationUseCase
}

func NewNotificationHandler(uc usecase.NotificationUseCase) *NotificationHandler {
	return &NotificationHandler{uc: uc}
}

func (h *NotificationHandler) List(c *gin.Context) {
	userIDStr := c.GetString("user_id")
	userID, _ := uuid.Parse(userIDStr)

	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
	offset, _ := strconv.Atoi(c.DefaultQuery("offset", "0"))

	notifs, err := h.uc.GetMyNotifications(c.Request.Context(), userID, limit, offset)
	if err != nil {
		response.Fail(c, http.StatusInternalServerError, err.Error())
		return
	}

	response.OK(c, notifs)
}

func (h *NotificationHandler) MarkAsRead(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid notification id")
		return
	}

	err = h.uc.MarkAsRead(c.Request.Context(), id)
	if err != nil {
		response.Fail(c, http.StatusInternalServerError, err.Error())
		return
	}

	response.OK(c, nil, "notification marked as read")
}

func (h *NotificationHandler) MarkAllAsRead(c *gin.Context) {
	userIDStr := c.GetString("user_id")
	userID, _ := uuid.Parse(userIDStr)

	err := h.uc.MarkAllAsRead(c.Request.Context(), userID)
	if err != nil {
		response.Fail(c, http.StatusInternalServerError, err.Error())
		return
	}

	response.OK(c, nil, "all notifications marked as read")
}

func (h *NotificationHandler) GetUnreadCount(c *gin.Context) {
	userIDStr := c.GetString("user_id")
	userID, _ := uuid.Parse(userIDStr)

	count, err := h.uc.GetUnreadCount(c.Request.Context(), userID)
	if err != nil {
		response.Fail(c, http.StatusInternalServerError, err.Error())
		return
	}

	response.OK(c, gin.H{"unread_count": count})
}

func (h *NotificationHandler) ServeWS(c *gin.Context) {
	val, exists := c.Get("user_id")
	if !exists {
		val = c.Query("token")
		if val == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
			return
		}
	}

	userIDStr, _ := val.(string)
	if userIDStr == "" {
		userIDStr = c.Query("user_id")
	}

	if userIDStr == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "no user_id provided"})
		return
	}

	websocket.DefaultHub.ServeWs(c.Writer, c.Request, userIDStr)
}
