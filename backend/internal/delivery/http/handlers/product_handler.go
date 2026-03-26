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

type ProductHandler struct {
	uc usecase.ProductUseCase
}

func NewProductHandler(uc usecase.ProductUseCase) *ProductHandler {
	return &ProductHandler{uc: uc}
}

// === Categories ===

func (h *ProductHandler) CreateCategory(c *gin.Context) {
	var req models.ProductCategory
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid payload", err.Error())
		return
	}

	cat, err := h.uc.CreateCategory(c.Request.Context(), &req)
	if err != nil {
		response.MapDBError(c, err)
		return
	}

	response.Created(c, cat)
}

func (h *ProductHandler) ListCategories(c *gin.Context) {
	cats, err := h.uc.ListCategories(c.Request.Context())
	if err != nil {
		response.MapDBError(c, err)
		return
	}
	response.OK(c, cats)
}

func (h *ProductHandler) UpdateCategory(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid category id")
		return
	}

	var req models.ProductCategory
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid payload payload")
		return
	}
	req.ID = id

	cat, err := h.uc.UpdateCategory(c.Request.Context(), &req)
	if err != nil {
		response.MapDBError(c, err)
		return
	}

	response.OK(c, cat, "category updated")
}

// === Products ===

func (h *ProductHandler) CreateProduct(c *gin.Context) {
	var req models.Product
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid payload")
		return
	}

	product, err := h.uc.CreateProduct(c.Request.Context(), &req)
	if err != nil {
		response.MapDBError(c, err)
		return
	}

	response.Created(c, product)
}

func (h *ProductHandler) GetProduct(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid product id")
		return
	}

	product, err := h.uc.GetProduct(c.Request.Context(), id)
	if err != nil {
		response.MapDBError(c, err)
		return
	}
	response.OK(c, product)
}

func (h *ProductHandler) ListProducts(c *gin.Context) {
	var filter repository.ProductFilter
	filter.Search = c.Query("search")
	
	if catStr := c.Query("category_id"); catStr != "" {
		if cid, err := uuid.Parse(catStr); err == nil {
			filter.CategoryID = &cid
		}
	}

	activeStr := c.Query("is_active")
	if activeStr == "true" {
		active := true
		filter.IsActive = &active
	} else if activeStr == "false" {
		active := false
		filter.IsActive = &active
	}

	products, err := h.uc.ListProducts(c.Request.Context(), filter)
	if err != nil {
		response.MapDBError(c, err)
		return
	}

	response.OK(c, products)
}

func (h *ProductHandler) UpdateProduct(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid product id")
		return
	}

	var req models.Product
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid payload payload")
		return
	}
	req.ID = id

	product, err := h.uc.UpdateProduct(c.Request.Context(), &req)
	if err != nil {
		response.MapDBError(c, err)
		return
	}

	response.OK(c, product, "product updated")
}

func (h *ProductHandler) DeleteProduct(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid product id")
		return
	}

	if err := h.uc.DeleteProduct(c.Request.Context(), id); err != nil {
		response.MapDBError(c, err)
		return
	}
	response.OK(c, nil, "product deleted")
}

// === Deal Items ===
// Nested conventionally underneath /deals/:id/items or separately

// AddDealItem Handles appending attachment to pipeline deal
func (h *ProductHandler) AddDealItem(c *gin.Context) {
	var req models.DealItem
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid payload")
		return
	}

	item, err := h.uc.AddDealItem(c.Request.Context(), &req)
	if err != nil {
		response.MapDBError(c, err)
		return
	}

	response.Created(c, item)
}

// ListDealItems By Deal Path Parameter
func (h *ProductHandler) ListDealItems(c *gin.Context) {
	dealID, err := uuid.Parse(c.Param("deal_id"))
	if err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid deal id")
		return
	}

	items, err := h.uc.ListDealItems(c.Request.Context(), dealID)
	if err != nil {
		response.MapDBError(c, err)
		return
	}
	response.OK(c, items)
}

func (h *ProductHandler) UpdateDealItem(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid item id")
		return
	}

	var req models.DealItem
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid payload format")
		return
	}
	req.ID = id

	item, err := h.uc.UpdateDealItem(c.Request.Context(), &req)
	if err != nil {
		response.MapDBError(c, err)
		return
	}

	response.OK(c, item, "deal item updated")
}

func (h *ProductHandler) RemoveDealItem(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.Fail(c, http.StatusBadRequest, "invalid item id")
		return
	}

	if err := h.uc.RemoveDealItem(c.Request.Context(), id); err != nil {
		response.MapDBError(c, err)
		return
	}
	response.OK(c, nil, "deal item removed successfully")
}
