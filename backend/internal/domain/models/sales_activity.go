package models

import (
	"time"

	"github.com/google/uuid"
)

type ActivityType string

const (
	ActivityTypeVisit       ActivityType = "visit"
	ActivityTypeNegotiation ActivityType = "negotiation"
	ActivityTypeDealClosing ActivityType = "deal_closing"
	ActivityTypeFollowUp    ActivityType = "follow_up"
	ActivityTypeOther       ActivityType = "other"
)

type SalesActivity struct {
	ID         uuid.UUID    `json:"id"`
	UserID     uuid.UUID    `json:"user_id"`
	LeadID     *uuid.UUID   `json:"lead_id,omitempty"`
	CustomerID *uuid.UUID   `json:"customer_id,omitempty"`
	DealID     *uuid.UUID   `json:"deal_id,omitempty"`
	Type       ActivityType `json:"type"`
	Title      string       `json:"title"`
	Notes      *string      `json:"notes,omitempty"`
	Latitude   *float64     `json:"latitude,omitempty"`
	Longitude  *float64     `json:"longitude,omitempty"`
	ActivityAt time.Time    `json:"activity_at"`
	CreatedAt  time.Time    `json:"created_at"`
	UpdatedAt  time.Time    `json:"updated_at"`
}
