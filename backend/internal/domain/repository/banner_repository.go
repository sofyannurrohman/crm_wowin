package repository

import (
	"context"
	"crm_wowin_backend/internal/domain/models"
	"github.com/google/uuid"
)

type BannerRepository interface {
	Create(ctx context.Context, banner *models.Banner) error
	GetByID(ctx context.Context, id uuid.UUID) (*models.Banner, error)
	List(ctx context.Context, filter BannerFilter) ([]*models.Banner, error)
}

type BannerFilter struct {
	SalesID    *uuid.UUID
	CustomerID *uuid.UUID
	LeadID     *uuid.UUID
	Limit      int
	Offset     int
}
