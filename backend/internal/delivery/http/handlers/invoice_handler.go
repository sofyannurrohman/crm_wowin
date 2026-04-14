package handlers

import (
	"crm_wowin_backend/internal/usecase"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type InvoiceHandler struct {
	useCase usecase.InvoiceUseCase
}

func NewInvoiceHandler(useCase usecase.InvoiceUseCase) *InvoiceHandler {
	return &InvoiceHandler{useCase: useCase}
}

func (h *InvoiceHandler) GetCustomerInvoices(c *gin.Context) {
	customerIDStr := c.Param("customerId")
	customerID, err := uuid.Parse(customerIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid customer id"})
		return
	}

	invoices, err := h.useCase.GetUnpaidInvoices(c.Request.Context(), customerID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": invoices})
}

func (h *InvoiceHandler) GetInvoice(c *gin.Context) {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid id"})
		return
	}

	invoice, err := h.useCase.GetInvoice(c.Request.Context(), id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	if invoice == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "invoice not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": invoice})
}
