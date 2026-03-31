package handlers

import (
	"crm_wowin_backend/internal/usecase"
	"crm_wowin_backend/pkg/response"
	"net/http"

	"github.com/gin-gonic/gin"
)

type SettingsHandler struct {
	uc usecase.SettingsUseCase
}

func NewSettingsHandler(uc usecase.SettingsUseCase) *SettingsHandler {
	return &SettingsHandler{uc: uc}
}

func (h *SettingsHandler) GetSettings(c *gin.Context) {
	settings, err := h.uc.GetSettings(c.Request.Context())
	if err != nil {
		response.MapDBError(c, err)
		return
	}
	response.OK(c, settings)
}

func (h *SettingsHandler) UpdateSetting(c *gin.Context) {
	var req struct {
		Value interface{} `json:"value" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid payload")
		return
	}

	key := c.Param("key")
	userID := c.GetString("user_id")

	err := h.uc.UpdateSetting(c.Request.Context(), key, req.Value, userID)
	if err != nil {
		response.MapDBError(c, err)
		return
	}

	response.OK(c, nil, "setting updated")
}
