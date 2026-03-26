package handlers

import (
	"crm_wowin_backend/internal/usecase"
	"crm_wowin_backend/pkg/response"
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
