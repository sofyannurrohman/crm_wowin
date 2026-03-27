package handlers

import (
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/usecase"
	"crm_wowin_backend/pkg/response"
	"net/http"

	"github.com/gin-gonic/gin"
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
