package handlers

import (
	"crm_wowin_backend/internal/usecase"
	"crm_wowin_backend/pkg/response"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

type ReportHandler struct {
	uc usecase.ReportUseCase
}

func NewReportHandler(uc usecase.ReportUseCase) *ReportHandler {
	return &ReportHandler{uc: uc}
}

func (h *ReportHandler) GetKpiSummary(c *gin.Context) {
	salesID := c.GetString("user_id")
	role := c.GetString("user_role")
	if salesID == "" {
		response.Fail(c, http.StatusUnauthorized, "missing user session")
		return
	}

	kpi, err := h.uc.GetDashboardSummary(c.Request.Context(), salesID, role)
	if err != nil {
		response.Fail(c, http.StatusInternalServerError, err.Error())
		return
	}
	response.OK(c, kpi)
}

func (h *ReportHandler) GetAnalytics(c *gin.Context) {
	monthsStr := c.DefaultQuery("months", "6")
	months, _ := strconv.Atoi(monthsStr)

	data, err := h.uc.GetAnalytics(c.Request.Context(), months)
	if err != nil {
		response.Fail(c, http.StatusInternalServerError, err.Error())
		return
	}
	response.OK(c, data)
}

func (h *ReportHandler) GetVisitRecommendations(c *gin.Context) {
	salesID := c.GetString("user_id")
	if salesID == "" {
		response.Fail(c, http.StatusUnauthorized, "missing user session")
		return
	}

	data, err := h.uc.GetVisitRecommendations(c.Request.Context(), salesID)
	if err != nil {
		response.Fail(c, http.StatusInternalServerError, err.Error())
		return
	}
	response.OK(c, data)
}
