package repository

import (
	"context"
	"crm_wowin_backend/internal/domain/models"

	"github.com/google/uuid"
)

type WarehouseRepository interface {
	Create(ctx context.Context, warehouse *models.Warehouse) error
	GetByID(ctx context.Context, id uuid.UUID) (*models.Warehouse, error)
	List(ctx context.Context) ([]*models.Warehouse, error)
	Update(ctx context.Context, warehouse *models.Warehouse) error
	Delete(ctx context.Context, id uuid.UUID) error
}
