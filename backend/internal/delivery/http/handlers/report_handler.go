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
	kpi, err := h.uc.GetDashboardSummary(c.Request.Context())
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
