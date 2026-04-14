package handlers

import (
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"
	"crm_wowin_backend/internal/usecase"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type StockTransferHandler struct {
	useCase usecase.StockTransferUseCase
}

func NewStockTransferHandler(useCase usecase.StockTransferUseCase) *StockTransferHandler {
	return &StockTransferHandler{useCase: useCase}
}

func (h *StockTransferHandler) CreateTransfer(c *gin.Context) {
	var st models.StockTransfer
	if err := c.ShouldBindJSON(&st); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// For sales, we ensure SalesID matches current user
	salesID := c.MustGet("userID").(uuid.UUID)
	st.SalesID = salesID

	created, err := h.useCase.RequestTransfer(c.Request.Context(), &st)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"data": created})
}

func (h *StockTransferHandler) GetTransfer(c *gin.Context) {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid id"})
		return
	}

	st, err := h.useCase.GetTransfer(c.Request.Context(), id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	if st == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "transfer not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": st})
}

func (h *StockTransferHandler) ListTransfers(c *gin.Context) {
	salesIDStr := c.Query("sales_id")
	statusStr := c.Query("status")
	
	filter := repository.StockTransferFilter{}
	if salesIDStr != "" {
		sid, _ := uuid.Parse(salesIDStr)
		filter.SalesID = &sid
	}
	if statusStr != "" {
		st := models.StockTransferStatus(statusStr)
		filter.Status = &st
	}

	transfers, err := h.useCase.ListTransfers(c.Request.Context(), filter)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": transfers})
}

func (h *StockTransferHandler) ApproveTransfer(c *gin.Context) {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid id"})
		return
	}

	if err := h.useCase.ApproveTransfer(c.Request.Context(), id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "transfer approved and stock updated"})
}

func (h *StockTransferHandler) RejectTransfer(c *gin.Context) {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid id"})
		return
	}

	var req struct {
		Reason string `json:"reason"`
	}
	_ = c.ShouldBindJSON(&req)

	if err := h.useCase.RejectTransfer(c.Request.Context(), id, req.Reason); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "transfer rejected"})
}
