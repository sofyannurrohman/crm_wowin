package models

import (
	"time"

	"github.com/google/uuid"
)

type ScheduleStatus string

const (
	ScheduleStatusScheduled ScheduleStatus = "scheduled"
	ScheduleStatusCompleted ScheduleStatus = "completed"
	ScheduleStatusCancelled ScheduleStatus = "cancelled"
	ScheduleStatusMissed    ScheduleStatus = "missed"
)

// VisitSchedule represents a planned visit from Sales to Customer
type VisitSchedule struct {
	ID          uuid.UUID      `json:"id"`
	SalesID     uuid.UUID      `json:"sales_id"` // User ID
	CustomerID  uuid.UUID      `json:"customer_id"`
	DealID      *uuid.UUID     `json:"deal_id,omitempty"` // Optional linkage to sales pipeline
	Date        time.Time      `json:"date"` // Just the YYYY-MM-DD conceptual representation mapped as Date type in DB
	Title       string         `json:"title"`
	Objective   *string        `json:"objective,omitempty"`
	Status      ScheduleStatus `json:"status"`
	Notes       *string        `json:"notes,omitempty"`
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
}

type VisitType string

const (
	VisitTypeCheckIn  VisitType = "check-in"
	VisitTypeCheckOut VisitType = "check-out"
)

// VisitActivity holds the actual footprint/proof of attendance for Sales on the field
type VisitActivity struct {
	ID          uuid.UUID  `json:"id"`
	ScheduleID  *uuid.UUID `json:"schedule_id,omitempty"` // Nullable if an ad-hoc visit
	SalesID     uuid.UUID  `json:"sales_id"`
	CustomerID  uuid.UUID  `json:"customer_id"`
	DealID      *uuid.UUID `json:"deal_id,omitempty"` // Optional linkage to sales pipeline
	Type        VisitType  `json:"type"`
	Latitude    float64    `json:"latitude"`
	Longitude   float64    `json:"longitude"`
	PhotoPath        string     `json:"photo_path"`       // Server path e.g., /uploads/visits/1234.jpg (Legacy)
	SelfiePhotoPath  string     `json:"selfie_photo_path"` // Face validation photo
	PlacePhotoPath   string     `json:"place_photo_path"`  // Place validation photo
	Distance    *float64   `json:"distance,omitempty"` // Distance to customer HQ during check-in
	IsOffline   bool       `json:"is_offline"` // True if dispatched from SQLite backlog
	Notes       *string    `json:"notes,omitempty"`
	CreatedAt   time.Time  `json:"created_at"`
}
