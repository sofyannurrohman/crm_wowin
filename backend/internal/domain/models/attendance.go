package models

import (
	"time"

	"github.com/google/uuid"
)

type AttendanceType string

const (
	AttendanceTypeClockIn  AttendanceType = "clock_in"
	AttendanceTypeClockOut AttendanceType = "clock_out"
)

type Attendance struct {
	ID          uuid.UUID      `json:"id"`
	UserID      uuid.UUID      `json:"user_id"`
	Type        AttendanceType `json:"type" binding:"required"`
	Latitude    float64        `json:"latitude"`
	Longitude   float64        `json:"longitude"`
	Address     string         `json:"address"`
	PhotoPath   string         `json:"photo_path"`
	DeviceInfo  interface{}    `json:"device_info"`
	TimestampAt time.Time      `json:"timestamp_at"`
	Notes       string         `json:"notes"`
}

type DailyAttendance struct {
	UserID     uuid.UUID  `json:"user_id"`
	WorkDate   time.Time  `json:"work_date"`
	ClockIn    *time.Time `json:"clock_in"`
	ClockOut   *time.Time `json:"clock_out"`
	WorkHours  float64    `json:"work_hours"`
}
