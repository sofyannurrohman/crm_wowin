package repository

import (
	"context"
	"crm_wowin_backend/internal/domain/models"

	"github.com/google/uuid"
)

type VanStockRepository interface {
	GetByUser(ctx context.Context, userID uuid.UUID) ([]*models.VanStock, error)
	GetByUserAndProduct(ctx context.Context, userID, productID uuid.UUID) (*models.VanStock, error)
	Update(ctx context.Context, vs *models.VanStock) error
	Create(ctx context.Context, vs *models.VanStock) error
	DeductStock(ctx context.Context, userID, productID uuid.UUID, quantity float64) error
}
