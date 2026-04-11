package handlers

import (
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/usecase"
	"crm_wowin_backend/pkg/response"
	"fmt"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type TargetHandler struct {
	uc usecase.TargetUseCase
}

func NewTargetHandler(uc usecase.TargetUseCase) *TargetHandler {
	return &TargetHandler{uc: uc}
}

func (h *TargetHandler) Get(c *gin.Context) {
	t, err := h.uc.Get(c.Request.Context())
	if err != nil {
		response.MapDBError(c, err)
		return
	}
	response.OK(c, t)
}

func (h *TargetHandler) Update(c *gin.Context) {
	var target models.Target
	if err := c.ShouldBindJSON(&target); err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid payload format")
		return
	}

	if err := h.uc.Update(c.Request.Context(), &target); err != nil {
		response.MapDBError(c, err)
		return
	}
	response.OK(c, target, "system targets updated")
}

func (h *TargetHandler) GetForUser(c *gin.Context) {
	userIDStr := c.Param("userID")
	userID, err := uuid.Parse(userIDStr)
	if err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid user id")
		return
	}

	monthStr := c.Query("month")
	yearStr := c.Query("year")
	
	// Default to current month/year if not provided
	now := time.Now()
	month := int(now.Month())
	year := now.Year()
	
	if monthStr != "" {
		fmt.Sscanf(monthStr, "%d", &month)
	}
	if yearStr != "" {
		fmt.Sscanf(yearStr, "%d", &year)
	}

	t, err := h.uc.GetForUser(c.Request.Context(), userID, month, year)
	if err != nil {
		response.MapDBError(c, err)
		return
	}
	response.OK(c, t)
}

func (h *TargetHandler) UpdateForUser(c *gin.Context) {
	var target models.SalesTarget
	if err := c.ShouldBindJSON(&target); err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid payload format")
		return
	}

	if err := h.uc.UpdateForUser(c.Request.Context(), &target); err != nil {
		response.MapDBError(c, err)
		return
	}
	response.OK(c, target, "individual target updated")
}
