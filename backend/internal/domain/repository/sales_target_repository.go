package repository

import (
	"context"
	"crm_wowin_backend/internal/domain/models"

	"github.com/google/uuid"
)

type SalesTargetRepository interface {
	GetByUserID(ctx context.Context, userID uuid.UUID, month, year int) (*models.SalesTarget, error)
	Upsert(ctx context.Context, target *models.SalesTarget) error
	FindByUserID(ctx context.Context, userID uuid.UUID) ([]*models.SalesTarget, error)
}
