package models

import (
	"time"

	"github.com/google/uuid"
)

// VanStock represents inventory carried by a specific salesman (Canvas mode)
type VanStock struct {
	ID        uuid.UUID `json:"id"`
	UserID    uuid.UUID `json:"user_id"`
	ProductID uuid.UUID `json:"product_id"`
	Product   *Product  `json:"product,omitempty"`
	Quantity  float64   `json:"quantity"`
	UpdatedAt time.Time `json:"updated_at"`
}
