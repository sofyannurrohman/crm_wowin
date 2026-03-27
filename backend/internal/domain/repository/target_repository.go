package repository

import (
	"context"
	"crm_wowin_backend/internal/domain/models"
)

type TargetRepository interface {
	Get(ctx context.Context) (*models.Target, error)
	Upsert(ctx context.Context, target *models.Target) error
}
