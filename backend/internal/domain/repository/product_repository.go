package repository

import (
	"context"
	"crm_wowin_backend/internal/domain/models"

	"github.com/google/uuid"
)

type ProductFilter struct {
	CategoryID *uuid.UUID
	Search     string
	IsActive   *bool
}

type ProductRepository interface {
	// Categories
	CreateCategory(ctx context.Context, category *models.ProductCategory) error
	GetCategoryByID(ctx context.Context, id uuid.UUID) (*models.ProductCategory, error)
	ListCategories(ctx context.Context) ([]*models.ProductCategory, error)
	UpdateCategory(ctx context.Context, category *models.ProductCategory) error

	// Products
	Create(ctx context.Context, product *models.Product) error
	GetByID(ctx context.Context, id uuid.UUID) (*models.Product, error)
	List(ctx context.Context, filter ProductFilter) ([]*models.Product, error)
	Update(ctx context.Context, product *models.Product) error
	Delete(ctx context.Context, id uuid.UUID) error
}

type DealItemRepository interface {
	// Attaches a product to a deal
	AddItem(ctx context.Context, item *models.DealItem) error
	GetItemsByDealID(ctx context.Context, dealID uuid.UUID) ([]*models.DealItem, error)
	GetItemByID(ctx context.Context, id uuid.UUID) (*models.DealItem, error)
	UpdateItem(ctx context.Context, item *models.DealItem) error
	RemoveItem(ctx context.Context, itemID uuid.UUID) error
	
	// Helper specifically calling DB function fn_calculate_deal_amount to sum it up manually if needed.
	SyncDealAmount(ctx context.Context, dealID uuid.UUID) error
}
