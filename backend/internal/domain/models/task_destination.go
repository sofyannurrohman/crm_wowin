package models

import (
	"time"

	"github.com/google/uuid"
)

type TaskDestination struct {
	ID            uuid.UUID   `json:"id"`
	TaskID        uuid.UUID   `json:"task_id"`
	LeadID        *uuid.UUID  `json:"lead_id,omitempty"`
	CustomerID    *uuid.UUID  `json:"customer_id,omitempty"`
	DealID        *uuid.UUID  `json:"deal_id,omitempty"`
	SequenceOrder int         `json:"sequence_order"`
	Status        TaskStatus  `json:"status"` // Reuse TaskStatus string constants
	CreatedAt     time.Time   `json:"created_at"`
	UpdatedAt     time.Time   `json:"updated_at"`

	// Joined attributes for convenience in response
	TargetName      string   `json:"target_name,omitempty"`
	TargetLatitude  *float64 `json:"target_latitude,omitempty"`
	TargetLongitude *float64 `json:"target_longitude,omitempty"`
	TargetAddress   *string  `json:"target_address,omitempty"`
}
