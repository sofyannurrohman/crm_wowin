package handlers

import (
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/usecase"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type WarehouseHandler struct {
	usecase usecase.WarehouseUseCase
}

func NewWarehouseHandler(uc usecase.WarehouseUseCase) *WarehouseHandler {
	return &WarehouseHandler{usecase: uc}
}

func (h *WarehouseHandler) RegisterRoutes(r *gin.RouterGroup) {
	warehouses := r.Group("/warehouses")
	{
		warehouses.POST("", h.Create)
		warehouses.GET("", h.List)
		warehouses.GET("/:id", h.GetByID)
		warehouses.PUT("/:id", h.Update)
		warehouses.DELETE("/:id", h.Delete)
	}
}

func (h *WarehouseHandler) Create(c *gin.Context) {
	var body models.Warehouse
	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	created, err := h.usecase.CreateWarehouse(c.Request.Context(), &body)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, created)
}

func (h *WarehouseHandler) List(c *gin.Context) {
	warehouses, err := h.usecase.ListWarehouses(c.Request.Context())
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, warehouses)
}

func (h *WarehouseHandler) GetByID(c *gin.Context) {
	idParam := c.Param("id")
	id, err := uuid.Parse(idParam)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid ID format"})
		return
	}

	warehouse, err := h.usecase.GetWarehouse(c.Request.Context(), id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "warehouse not found"})
		return
	}

	c.JSON(http.StatusOK, warehouse)
}

func (h *WarehouseHandler) Update(c *gin.Context) {
	idParam := c.Param("id")
	id, err := uuid.Parse(idParam)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid ID format"})
		return
	}

	var body models.Warehouse
	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	body.ID = id

	updated, err := h.usecase.UpdateWarehouse(c.Request.Context(), &body)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, updated)
}

func (h *WarehouseHandler) Delete(c *gin.Context) {
	idParam := c.Param("id")
	id, err := uuid.Parse(idParam)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid ID format"})
		return
	}

	if err := h.usecase.DeleteWarehouse(c.Request.Context(), id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "warehouse deleted successfully"})
}
