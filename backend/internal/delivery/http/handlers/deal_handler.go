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

type LeadHandler struct {
	uc usecase.LeadUseCase
}

func NewLeadHandler(uc usecase.LeadUseCase) *LeadHandler {
	return &LeadHandler{uc: uc}
}

func (h *LeadHandler) CreateLead(c *gin.Context) {
	var req models.Lead
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid payload", err.Error())
		return
	}

	userIDStr := c.GetString("user_id")
	userID, _ := uuid.Parse(userIDStr)

	lead, err := h.uc.CreateLead(c.Request.Context(), &req, userID)
	if err != nil {
		response.MapDBError(c, err)
		return
	}

	response.Created(c, lead)
}

func (h *LeadHandler) GetLead(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid id")
		return
	}

	lead, err := h.uc.GetLead(c.Request.Context(), id)
	if err != nil {
		response.MapDBError(c, err)
		return
	}
	response.OK(c, lead)
}

func (h *LeadHandler) ListLeads(c *gin.Context) {
	var filter repository.LeadFilter
	filter.Search = c.Query("search")
	filter.Status = c.Query("status")
	
	if assignStr := c.Query("assigned_to"); assignStr != "" {
		if aid, err := uuid.Parse(assignStr); err == nil {
			filter.AssignedTo = &aid
		}
	}

	leads, err := h.uc.ListLeads(c.Request.Context(), filter)
	if err != nil {
		response.MapDBError(c, err)
		return
	}

	response.OK(c, leads)
}

func (h *LeadHandler) UpdateLead(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid id")
		return
	}

	var req models.Lead
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid payload")
		return
	}
	req.ID = id

	lead, err := h.uc.UpdateLead(c.Request.Context(), &req)
	if err != nil {
		response.MapDBError(c, err)
		return
	}

	response.OK(c, lead, "lead updated")
}

func (h *LeadHandler) DeleteLead(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid id")
		return
	}

	if err := h.uc.DeleteLead(c.Request.Context(), id); err != nil {
		response.MapDBError(c, err)
		return
	}
	response.OK(c, nil, "lead deleted")
}

func (h *LeadHandler) ConvertLead(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid id")
		return
	}

	userIDStr := c.GetString("user_id")
	userID, _ := uuid.Parse(userIDStr)

	customer, err := h.uc.ConvertLeadToCustomer(c.Request.Context(), id, userID)
	if err != nil {
		response.MapDBError(c, err)
		return
	}

	response.OK(c, customer, "lead successfully converted to customer")
}


// ==============
// DEAL HANDLER
// ==============

type DealHandler struct {
	uc usecase.DealUseCase
}

func NewDealHandler(uc usecase.DealUseCase) *DealHandler {
	return &DealHandler{uc: uc}
}

func (h *DealHandler) CreateDeal(c *gin.Context) {
	var req models.Deal
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid payload")
		return
	}

	userIDStr := c.GetString("user_id")
	userID, _ := uuid.Parse(userIDStr)

	deal, err := h.uc.CreateDeal(c.Request.Context(), &req, userID)
	if err != nil {
		response.MapDBError(c, err)
		return
	}

	response.Created(c, deal)
}

func (h *DealHandler) ListDeals(c *gin.Context) {
	var filter repository.DealFilter
	filter.Stage = c.Query("stage")
	filter.Status = c.Query("status")
	
	if custStr := c.Query("customer_id"); custStr != "" {
		if cid, err := uuid.Parse(custStr); err == nil {
			filter.CustomerID = &cid
		}
	}
	if assignStr := c.Query("assigned_to"); assignStr != "" {
		if aid, err := uuid.Parse(assignStr); err == nil {
			filter.AssignedTo = &aid
		}
	}

	deals, err := h.uc.ListDeals(c.Request.Context(), filter)
	if err != nil {
		response.MapDBError(c, err)
		return
	}

	response.OK(c, deals)
}

func (h *DealHandler) GetDeal(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid id")
		return
	}

	deal, history, err := h.uc.GetDealDetails(c.Request.Context(), id)
	if err != nil {
		response.MapDBError(c, err)
		return
	}

	response.OK(c, gin.H{
		"deal":    deal,
		"history": history,
	})
}

func (h *DealHandler) UpdateDeal(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid id")
		return
	}

	var req models.Deal
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid payload")
		return
	}
	req.ID = id
	
	deal, err := h.uc.UpdateDeal(c.Request.Context(), &req)
	if err != nil {
		response.MapDBError(c, err)
		return
	}

	response.OK(c, deal, "deal updated")
}

// UpdateStage handles the Kanban Drag and Drop payload
func (h *DealHandler) UpdateStage(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid id")
		return
	}

	var req struct {
		Stage  string  `json:"stage" binding:"required"`
		Notes  *string `json:"notes"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid payload format")
		return
	}

	userIDStr := c.GetString("user_id")
	userID, _ := uuid.Parse(userIDStr)

	err = h.uc.ChangeDealStage(c.Request.Context(), id, models.DealStage(req.Stage), userID, req.Notes)
	if err != nil {
		response.MapDBError(c, err)
		return
	}

	response.OK(c, nil, "deal stage updated successfully")
}
