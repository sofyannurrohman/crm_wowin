package models

import (
	"time"

	"github.com/google/uuid"
)

type TerritoryStatus string

const (
	TerritoryStatusActive   TerritoryStatus = "active"
	TerritoryStatusInactive TerritoryStatus = "inactive"
)

type Territory struct {
	ID          uuid.UUID       `json:"id"`
	Name        string          `json:"name" binding:"required"`
	Description string          `json:"description"`
	Geometry    interface{}     `json:"geometry" binding:"required"` // Expecting GeoJSON MultiPolygon
	Color       string          `json:"color"`
	Status      TerritoryStatus `json:"status"`
	CreatedBy   *uuid.UUID      `json:"created_by"`
	CreatedAt   time.Time       `json:"created_at"`
	UpdatedAt   time.Time       `json:"updated_at"`
}

type TerritoryUser struct {
	TerritoryID uuid.UUID `json:"territory_id"`
	UserID      uuid.UUID `json:"user_id"`
	AssignedAt  time.Time `json:"assigned_at"`
	AssignedBy  uuid.UUID `json:"assigned_by"`
}
