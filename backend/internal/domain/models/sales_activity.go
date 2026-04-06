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
	ID           uuid.UUID    `json:"id"`
	UserID       uuid.UUID    `json:"user_id"`
	LeadID            *uuid.UUID   `json:"lead_id,omitempty"`
	CustomerID        *uuid.UUID   `json:"customer_id,omitempty"`
	DealID            *uuid.UUID   `json:"deal_id,omitempty"`
	TaskDestinationID *uuid.UUID   `json:"task_destination_id,omitempty"`
	Type              ActivityType `json:"type"`
	Title        string       `json:"title"`
	Notes        *string      `json:"notes,omitempty"`
	Latitude     *float64     `json:"latitude,omitempty"`
	Longitude    *float64     `json:"longitude,omitempty"`
	CheckInTime            *time.Time   `json:"check_in_time,omitempty"`
	CheckOutTime           *time.Time   `json:"check_out_time,omitempty"`
	PhotoBase64            *string      `json:"photo_base64,omitempty"`
	StorefrontPhotoBase64  *string      `json:"storefront_photo_base64,omitempty"`
	Address                *string      `json:"address,omitempty"`
	Outcome                *string      `json:"outcome,omitempty"`
	ActivityAt             time.Time    `json:"activity_at"`
	CreatedAt              time.Time    `json:"created_at"`
	UpdatedAt              time.Time    `json:"updated_at"`
}
