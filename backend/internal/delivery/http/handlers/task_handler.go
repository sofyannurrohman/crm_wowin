package handlers

import (
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"
	"crm_wowin_backend/internal/usecase"
	"crm_wowin_backend/pkg/response"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type TaskHandler struct {
	uc usecase.TaskUseCase
}

func NewTaskHandler(uc usecase.TaskUseCase) *TaskHandler {
	return &TaskHandler{uc: uc}
}

func (h *TaskHandler) Create(c *gin.Context) {
	var t models.Task
	if err := c.ShouldBindJSON(&t); err != nil {
		response.Fail(c, http.StatusBadRequest, err.Error())
		return
	}

	salesID, _ := uuid.Parse(c.GetString("user_id"))
	t.SalesID = salesID

	created, err := h.uc.Create(c.Request.Context(), &t)
	if err != nil {
		response.Fail(c, http.StatusInternalServerError, err.Error())
		return
	}

	response.Created(c, created)
}

func (h *TaskHandler) List(c *gin.Context) {
	var filter repository.TaskFilter
	
	salesIDStr := c.Query("sales_id")
	if salesIDStr != "" {
		if u, err := uuid.Parse(salesIDStr); err == nil {
			filter.SalesID = &u
		}
	} else {
		// Default to current user
		u, _ := uuid.Parse(c.GetString("user_id"))
		filter.SalesID = &u
	}

	if cID := c.Query("customer_id"); cID != "" {
		if u, err := uuid.Parse(cID); err == nil {
			filter.CustomerID = &u
		}
	}

	filter.Status = models.TaskStatus(c.Query("status"))

	tasks, err := h.uc.List(c.Request.Context(), filter)
	if err != nil {
		response.Fail(c, http.StatusInternalServerError, err.Error())
		return
	}

	response.OK(c, tasks)
}

func (h *TaskHandler) Update(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid id")
		return
	}

	var t models.Task
	if err := c.ShouldBindJSON(&t); err != nil {
		response.Fail(c, http.StatusBadRequest, err.Error())
		return
	}
	t.ID = id

	updated, err := h.uc.Update(c.Request.Context(), &t)
	if err != nil {
		response.Fail(c, http.StatusInternalServerError, err.Error())
		return
	}

	response.OK(c, updated)
}

func (h *TaskHandler) Complete(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid id")
		return
	}

	if err := h.uc.Complete(c.Request.Context(), id); err != nil {
		response.Fail(c, http.StatusInternalServerError, err.Error())
		return
	}

	response.OK(c, nil)
}

func (h *TaskHandler) Delete(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid id")
		return
	}

	if err := h.uc.Delete(c.Request.Context(), id); err != nil {
		response.Fail(c, http.StatusInternalServerError, err.Error())
		return
	}

	response.OK(c, nil)
}
