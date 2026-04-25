package models

import (
	"crm_wowin_backend/pkg/utils"

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
	ID                uuid.UUID      `json:"id"`
	UserID            uuid.UUID      `json:"user_id"`
	LeadID            *uuid.UUID     `json:"lead_id,omitempty"`
	CustomerID        *uuid.UUID     `json:"customer_id,omitempty"`
	DealID            *uuid.UUID     `json:"deal_id,omitempty"`
	DealTitle         *string        `json:"deal_title,omitempty"`
	TaskDestinationID *uuid.UUID     `json:"task_destination_id,omitempty"`
	Type              ActivityType   `json:"type"`
	Title             string         `json:"title"`
	Notes             *string        `json:"notes,omitempty"`
	Latitude          *float64       `json:"latitude,omitempty"`
	Longitude         *float64       `json:"longitude,omitempty"`
	CheckInTime       *utils.FlexTime `json:"check_in_time,omitempty"`
	CheckOutTime      *utils.FlexTime `json:"check_out_time,omitempty"`
	SelfiePhotoPath   *string        `json:"selfie_photo_path,omitempty"`
	PlacePhotoPath    *string        `json:"place_photo_path,omitempty"`
	Distance          *float64       `json:"distance,omitempty"`
	IsOffline         bool           `json:"is_offline"`
	Address           *string        `json:"address,omitempty"`
	Outcome           *string        `json:"outcome,omitempty"`
	SignaturePath     *string        `json:"signature_path,omitempty"`
	CustomerName      *string        `json:"customer_name,omitempty"`
	LeadName          *string        `json:"lead_name,omitempty"`
	DealAmount        *float64       `json:"deal_amount,omitempty"`
	NotaPhotoPath     *string        `json:"nota_photo_path,omitempty"`
	Status            VisitStatus    `json:"status"`
	ActivityAt        utils.FlexTime  `json:"activity_at"`
	CreatedAt         utils.FlexTime  `json:"created_at"`
	UpdatedAt         utils.FlexTime  `json:"updated_at"`
}
