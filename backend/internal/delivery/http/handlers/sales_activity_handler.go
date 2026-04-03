package handlers

import (
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type SalesActivityHandler struct {
	repo repository.SalesActivityRepository
}

func NewSalesActivityHandler(repo repository.SalesActivityRepository) *SalesActivityHandler {
	return &SalesActivityHandler{repo: repo}
}

func (h *SalesActivityHandler) Create(c *gin.Context) {
	var a models.SalesActivity
	if err := c.ShouldBindJSON(&a); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Set salesman ID from auth context (assuming it's set by middleware)
	userID, exists := c.Get("user_id")
	if exists {
		if id, ok := userID.(uuid.UUID); ok {
			a.UserID = id
		} else if idStr, ok := userID.(string); ok {
			id, _ := uuid.Parse(idStr)
			a.UserID = id
		}
	}

	if a.ActivityAt.IsZero() {
		a.ActivityAt = time.Now()
	}

	if err := h.repo.Create(c.Request.Context(), &a); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, a)
}

func (h *SalesActivityHandler) List(c *gin.Context) {
	var filter repository.SalesActivityFilter

	if salesID := c.Query("sales_id"); salesID != "" {
		id, _ := uuid.Parse(salesID)
		filter.SalesID = &id
	}
	if leadID := c.Query("lead_id"); leadID != "" {
		id, _ := uuid.Parse(leadID)
		filter.LeadID = &id
	}
	if customerID := c.Query("customer_id"); customerID != "" {
		id, _ := uuid.Parse(customerID)
		filter.CustomerID = &id
	}
	if dealID := c.Query("deal_id"); dealID != "" {
		id, _ := uuid.Parse(dealID)
		filter.DealID = &id
	}

	activities, err := h.repo.List(c.Request.Context(), filter)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, activities)
}

func (h *SalesActivityHandler) Update(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}

	var a models.SalesActivity
	if err := c.ShouldBindJSON(&a); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	a.ID = id

	if err := h.repo.Update(c.Request.Context(), &a); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, a)
}

func (h *SalesActivityHandler) Delete(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}

	if err := h.repo.Delete(c.Request.Context(), id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusNoContent, nil)
}
