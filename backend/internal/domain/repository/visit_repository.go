package repository

import (
	"context"
	"crm_wowin_backend/internal/domain/models"
	"time"

	"github.com/google/uuid"
)

type ScheduleFilter struct {
	SalesID    *uuid.UUID
	LeadID     *uuid.UUID
	CustomerID *uuid.UUID
	Status     string
	StartDate  *time.Time
	EndDate    *time.Time
}

// VisitRepository handles the schedules and execution footprints of the field team
type VisitRepository interface {
	// Schedules
	CreateSchedule(ctx context.Context, schedule *models.VisitSchedule) error
	GetScheduleByID(ctx context.Context, id uuid.UUID) (*models.VisitSchedule, error)
	ListSchedules(ctx context.Context, filter ScheduleFilter) ([]*models.VisitSchedule, error)
	UpdateSchedule(ctx context.Context, schedule *models.VisitSchedule) error
	DeleteSchedule(ctx context.Context, id uuid.UUID) error

	// Execution Footprints (Check-ins / Check-outs)
	LogActivity(ctx context.Context, activity *models.VisitActivity) error
	GetActivitiesBySchedule(ctx context.Context, scheduleID uuid.UUID) ([]*models.VisitActivity, error)
	GetActivitiesByCustomer(ctx context.Context, customerID uuid.UUID) ([]*models.VisitActivity, error)
	GetActivitiesByLead(ctx context.Context, leadID uuid.UUID) ([]*models.VisitActivity, error)
	ListActivities(ctx context.Context, filter ActivityFilter) ([]*models.VisitActivity, error)
}

type ActivityFilter struct {
	SalesID    *uuid.UUID
	LeadID     *uuid.UUID
	CustomerID *uuid.UUID
	StartDate  *time.Time
	EndDate    *time.Time
}
