package models

import (
	"time"

	"github.com/google/uuid"
)

// ProductCategory groups the standard products for easier filtering
type ProductCategory struct {
	ID          uuid.UUID `json:"id"`
	Name        string    `json:"name"`
	Description *string   `json:"description,omitempty"`
	IsActive    bool      `json:"is_active"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

// Product represents a sellable catalog item
type Product struct {
	ID          uuid.UUID  `json:"id"`
	CategoryID  *uuid.UUID `json:"category_id,omitempty"`
	SKU         *string    `json:"sku,omitempty"`
	Name        string     `json:"name"`
	Description *string    `json:"description,omitempty"`
	Price       float64    `json:"price"` // Base standard price
	IsActive    bool       `json:"is_active"`
	CreatedAt   time.Time  `json:"created_at"`
	UpdatedAt   time.Time  `json:"updated_at"`
	DeletedAt   *time.Time `json:"deleted_at,omitempty"`
}

// DealItem represents the junction appending products into a deal 
type DealItem struct {
	ID          uuid.UUID `json:"id"`
	DealID      uuid.UUID `json:"deal_id"`
	ProductID   uuid.UUID `json:"product_id"`
	Quantity    int       `json:"quantity"`
	UnitPrice   float64   `json:"unit_price"`
	Discount    float64   `json:"discount"`
	Subtotal    float64   `json:"subtotal"` // Formula: (UnitPrice * Quantity) - Discount
	Notes       *string   `json:"notes,omitempty"`
	CreatedAt   time.Time `json:"created_at"`
}
