package models

import (
	"time"

	"github.com/google/uuid"
)

// ProductCategory groups the standard products for easier filtering
type ProductCategory struct {
	ID        uuid.UUID  `json:"id"`
	Name      string     `json:"name"`
	ParentID  *uuid.UUID `json:"parent_id,omitempty"`
	CreatedAt time.Time  `json:"created_at"`
}

// Product represents a sellable catalog item
type Product struct {
	ID          uuid.UUID  `json:"id"`
	CategoryID  *uuid.UUID `json:"category_id,omitempty"`
	SKU         *string    `json:"sku,omitempty"` // Mapped from 'code' in DB
	Name        string     `json:"name"`
	Description *string    `json:"description,omitempty"`
	Unit        *string    `json:"unit,omitempty"`
	Price       float64    `json:"price"` // Mapped from 'base_price' in DB
	IsActive    bool       `json:"is_active"`
	CreatedAt   time.Time  `json:"created_at"`
	UpdatedAt   time.Time  `json:"updated_at"`
}

// DealItem represents the junction appending products into a deal 
type DealItem struct {
	ID          uuid.UUID `json:"id"`
	DealID      *uuid.UUID `json:"deal_id,omitempty"`
	ProductID   uuid.UUID `json:"product_id"`
	Name        string    `json:"name"`
	Quantity    float64   `json:"quantity"` // Changed to float for fractions if needed
	Unit        string    `json:"unit"`     // pcs, dus, crate
	UnitPrice   float64   `json:"unit_price"`
	Discount    float64   `json:"discount"`
	Subtotal    float64   `json:"subtotal"` // Formula: (UnitPrice * Quantity) - Discount
	Notes       *string   `json:"notes,omitempty"`
	CreatedAt   time.Time `json:"created_at"`
}
