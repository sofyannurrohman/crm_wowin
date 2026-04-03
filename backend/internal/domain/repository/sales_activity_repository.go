package repository

import (
	"context"
	"crm_wowin_backend/internal/domain/models"
	"time"

	"github.com/google/uuid"
)

type SalesActivityFilter struct {
	SalesID    *uuid.UUID
	LeadID     *uuid.UUID
	CustomerID *uuid.UUID
	DealID     *uuid.UUID
	StartDate  *time.Time
	EndDate    *time.Time
}

type SalesActivityRepository interface {
	Create(ctx context.Context, activity *models.SalesActivity) error
	GetByID(ctx context.Context, id uuid.UUID) (*models.SalesActivity, error)
	List(ctx context.Context, filter SalesActivityFilter) ([]*models.SalesActivity, error)
	Update(ctx context.Context, activity *models.SalesActivity) error
	Delete(ctx context.Context, id uuid.UUID) error
}
