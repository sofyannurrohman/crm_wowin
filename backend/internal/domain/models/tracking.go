package models

import (
	"time"

	"github.com/google/uuid"
)

type TrackingStatus string

const (
	TrackingStatusOnTheWay TrackingStatus = "on_the_way"
	TrackingStatusAtLocation TrackingStatus = "at_location"
	TrackingStatusIdle      TrackingStatus = "idle"
	TrackingStatusOffline   TrackingStatus = "offline"
)

type LocationPoint struct {
	ID           int64     `json:"id"`
	SessionID    uuid.UUID `json:"session_id"`
	SalesID      uuid.UUID `json:"sales_id"`
	RecordedAt   time.Time `json:"recorded_at"`
	Latitude     float64   `json:"latitude"`
	Longitude    float64   `json:"longitude"`
	Accuracy     float64   `json:"accuracy"`
	Speed        float64   `json:"speed"`
	Heading      float64   `json:"heading"`
	Altitude     float64   `json:"altitude"`
	BatteryLevel int       `json:"battery_level"`
}

type TrackingSession struct {
	ID            uuid.UUID      `json:"id"`
	SalesID       uuid.UUID      `json:"sales_id"`
	SessionDate   time.Time      `json:"session_date"`
	StartedAt     *time.Time     `json:"started_at"`
	EndedAt       *time.Time     `json:"ended_at"`
	Status        TrackingStatus `json:"status"`
	TotalDistance float64        `json:"total_distance"`
	RouteGeoJSON  interface{}    `json:"route,omitempty"` // For GeoJSON representation
	CreatedAt     time.Time      `json:"created_at"`
	UpdatedAt     time.Time      `json:"updated_at"`
}

type SalesLivePosition struct {
	SalesID      uuid.UUID      `json:"sales_id"`
	SalesName    string         `json:"sales_name"`
	Latitude     float64        `json:"latitude"`
	Longitude    float64        `json:"longitude"`
	Status       TrackingStatus `json:"status"`
	Speed        float64        `json:"speed"`
	Heading      float64        `json:"heading"`
	BatteryLevel int            `json:"battery_level"`
	UpdatedAt    time.Time      `json:"updated_at"`
}
