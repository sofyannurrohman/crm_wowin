package handlers

import (
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/usecase"
	"crm_wowin_backend/pkg/response"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type TerritoryHandler struct {
	uc usecase.TerritoryUseCase
}

func NewTerritoryHandler(uc usecase.TerritoryUseCase) *TerritoryHandler {
	return &TerritoryHandler{uc: uc}
}

func (h *TerritoryHandler) Create(c *gin.Context) {
	var req models.Territory
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid payload")
		return
	}

	userIDStr := c.GetString("user_id")
	userID, _ := uuid.Parse(userIDStr)
	req.CreatedBy = &userID

	t, err := h.uc.CreateTerritory(c.Request.Context(), &req)
	if err != nil {
		response.Fail(c, http.StatusInternalServerError, err.Error())
		return
	}

	response.Created(c, t)
}

func (h *TerritoryHandler) List(c *gin.Context) {
	ts, err := h.uc.ListTerritories(c.Request.Context())
	if err != nil {
		response.Fail(c, http.StatusInternalServerError, err.Error())
		return
	}

	response.OK(c, ts)
}

func (h *TerritoryHandler) Get(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid territory id")
		return
	}

	t, err := h.uc.GetTerritory(c.Request.Context(), id)
	if err != nil {
		response.MapDBError(c, err)
		return
	}

	response.OK(c, t)
}

func (h *TerritoryHandler) Update(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid territory id")
		return
	}

	var req models.Territory
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid payload")
		return
	}
	req.ID = id

	t, err := h.uc.UpdateTerritory(c.Request.Context(), &req)
	if err != nil {
		response.Fail(c, http.StatusInternalServerError, err.Error())
		return
	}

	response.OK(c, t)
}

func (h *TerritoryHandler) Delete(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid territory id")
		return
	}

	err = h.uc.DeleteTerritory(c.Request.Context(), id)
	if err != nil {
		response.Fail(c, http.StatusInternalServerError, err.Error())
		return
	}

	response.OK(c, nil, "territory deleted")
}
