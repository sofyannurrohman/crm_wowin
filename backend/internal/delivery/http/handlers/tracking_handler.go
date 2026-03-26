package handlers

import (
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/usecase"
	"crm_wowin_backend/pkg/response"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type TrackingHandler struct {
	uc usecase.TrackingUseCase
}

func NewTrackingHandler(uc usecase.TrackingUseCase) *TrackingHandler {
	return &TrackingHandler{uc: uc}
}

type syncBatchRequest struct {
	Points []models.LocationPoint `json:"points" binding:"required"`
}

func (h *TrackingHandler) SyncPoints(c *gin.Context) {
	var req syncBatchRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid payload")
		return
	}

	userIDStr := c.GetString("user_id")
	userID, _ := uuid.Parse(userIDStr)

	err := h.uc.SyncPoints(c.Request.Context(), userID, req.Points)
	if err != nil {
		response.Fail(c, http.StatusInternalServerError, err.Error())
		return
	}

	response.OK(c, nil, "sync success")
}

func (h *TrackingHandler) GetLivePositions(c *gin.Context) {
	positions, err := h.uc.GetLivePositions(c.Request.Context())
	if err != nil {
		response.Fail(c, http.StatusInternalServerError, err.Error())
		return
	}

	response.OK(c, positions)
}

func (h *TrackingHandler) GetSessionRoute(c *gin.Context) {
	salesID, err := uuid.Parse(c.Param("sales_id"))
	if err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid sales id")
		return
	}

	dateStr := c.Query("date")
	if dateStr == "" {
		dateStr = time.Now().Format("2006-01-02")
	}

	date, err := time.Parse("2006-01-02", dateStr)
	if err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid date format (YYYY-MM-DD)")
		return
	}

	session, err := h.uc.GetSessionRoute(c.Request.Context(), salesID, date)
	if err != nil {
		response.Fail(c, http.StatusInternalServerError, err.Error())
		return
	}

	response.OK(c, session)
}
