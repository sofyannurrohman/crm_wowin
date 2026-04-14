package repository

import (
	"context"
	"crm_wowin_backend/internal/domain/models"
	"github.com/google/uuid"
)

type StockTransferFilter struct {
	SalesID     *uuid.UUID
	WarehouseID *uuid.UUID
	Status      *models.StockTransferStatus
	Type        *models.StockTransferType
}

type StockTransferRepository interface {
	Create(ctx context.Context, transfer *models.StockTransfer) error
	GetByID(ctx context.Context, id uuid.UUID) (*models.StockTransfer, error)
	List(ctx context.Context, filter StockTransferFilter) ([]*models.StockTransfer, error)
	UpdateStatus(ctx context.Context, id uuid.UUID, status models.StockTransferStatus) error
}
