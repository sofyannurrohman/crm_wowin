package handlers

import (
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"
	"crm_wowin_backend/internal/usecase"
	"crm_wowin_backend/pkg/response"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type CustomerHandler struct {
	uc usecase.CustomerUseCase
}

func NewCustomerHandler(uc usecase.CustomerUseCase) *CustomerHandler {
	return &CustomerHandler{uc: uc}
}

// CreateCustomer handles POST /customers
func (h *CustomerHandler) CreateCustomer(c *gin.Context) {
	var req models.Customer
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid payload", err.Error())
		return
	}

	// Extracts ID from Context (Set by Auth Middleware)
	userIDStr := c.GetString("user_id")
	userID, err := uuid.Parse(userIDStr)
	if err != nil {
		response.Fail(c, http.StatusUnauthorized, "invalid user authentication state")
		return
	}

	customer, err := h.uc.CreateCustomer(c.Request.Context(), &req, userID)
	if err != nil {
		response.MapDBError(c, err)
		return
	}

	response.Created(c, customer)
}

// GetCustomer retrieves Customer along with its Contacts
func (h *CustomerHandler) GetCustomer(c *gin.Context) {
	idParam := c.Param("id")
	id, err := uuid.Parse(idParam)
	if err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid customer id format")
		return
	}

	customer, contacts, err := h.uc.GetCustomerDetail(c.Request.Context(), id)
	if err != nil {
		response.MapDBError(c, err)
		return
	}

	response.OK(c, gin.H{
		"customer": customer,
		"contacts": contacts,
	})
}

// ListCustomers handles querying Customers
func (h *CustomerHandler) ListCustomers(c *gin.Context) {
	var filter repository.CustomerFilter
	
	filter.Search = c.Query("search")
	filter.Status = c.Query("status")
	filter.Type = c.Query("type")
	
	if assignStr := c.Query("assigned_to"); assignStr != "" {
		if aid, err := uuid.Parse(assignStr); err == nil {
			filter.AssignedTo = &aid
		}
	}

	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "50"))
	offset, _ := strconv.Atoi(c.DefaultQuery("offset", "0"))
	filter.Limit = limit
	filter.Offset = offset

	results, total, err := h.uc.ListCustomers(c.Request.Context(), filter)
	if err != nil {
		response.MapDBError(c, err)
		return
	}

	c.JSON(http.StatusOK, response.Success{
		Code:    http.StatusOK,
		Message: "fetched successfully",
		Data:    results,
		Meta: gin.H{
			"total":  total,
			"limit":  limit,
			"offset": offset,
		},
	})
}

// UpdateCustomer handles PUT /customers/:id
func (h *CustomerHandler) UpdateCustomer(c *gin.Context) {
	idParam := c.Param("id")
	id, err := uuid.Parse(idParam)
	if err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid customer id format")
		return
	}

	var req models.Customer
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid payload payload", err.Error())
		return
	}
	req.ID = id // Secure the ID from params

	customer, err := h.uc.UpdateCustomer(c.Request.Context(), &req)
	if err != nil {
		response.MapDBError(c, err)
		return
	}

	response.OK(c, customer, "customer updated successfully")
}

// DeleteCustomer handles DELETE /customers/:id
func (h *CustomerHandler) DeleteCustomer(c *gin.Context) {
	idParam := c.Param("id")
	id, err := uuid.Parse(idParam)
	if err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid customer id format")
		return
	}

	if err := h.uc.DeleteCustomer(c.Request.Context(), id); err != nil {
		response.MapDBError(c, err)
		return
	}

	response.OK(c, nil, "customer deleted successfully")
}

// AddContact handles POST /customers/:id/contacts
func (h *CustomerHandler) AddContact(c *gin.Context) {
	idParam := c.Param("id")
	customerID, err := uuid.Parse(idParam)
	if err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid customer id format")
		return
	}

	var req models.Contact
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid payload payload", err.Error())
		return
	}
	
	req.CustomerID = customerID // Link safely

	contact, err := h.uc.AddContact(c.Request.Context(), &req)
	if err != nil {
		response.MapDBError(c, err)
		return
	}

	response.Created(c, contact)
}
