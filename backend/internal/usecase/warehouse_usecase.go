package usecase

import (
	"context"
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"

	"github.com/google/uuid"
)

type WarehouseUseCase interface {
	CreateWarehouse(ctx context.Context, warehouse *models.Warehouse) (*models.Warehouse, error)
	GetWarehouse(ctx context.Context, id uuid.UUID) (*models.Warehouse, error)
	ListWarehouses(ctx context.Context) ([]*models.Warehouse, error)
	UpdateWarehouse(ctx context.Context, warehouse *models.Warehouse) (*models.Warehouse, error)
	DeleteWarehouse(ctx context.Context, id uuid.UUID) error
}

type warehouseUseCaseImpl struct {
	repo repository.WarehouseRepository
}

func NewWarehouseUseCase(repo repository.WarehouseRepository) WarehouseUseCase {
	return &warehouseUseCaseImpl{repo: repo}
}

func (u *warehouseUseCaseImpl) CreateWarehouse(ctx context.Context, w *models.Warehouse) (*models.Warehouse, error) {
	if err := u.repo.Create(ctx, w); err != nil {
		return nil, err
	}
	return w, nil
}

func (u *warehouseUseCaseImpl) GetWarehouse(ctx context.Context, id uuid.UUID) (*models.Warehouse, error) {
	return u.repo.GetByID(ctx, id)
}

func (u *warehouseUseCaseImpl) ListWarehouses(ctx context.Context) ([]*models.Warehouse, error) {
	return u.repo.List(ctx)
}

func (u *warehouseUseCaseImpl) UpdateWarehouse(ctx context.Context, w *models.Warehouse) (*models.Warehouse, error) {
	_, err := u.repo.GetByID(ctx, w.ID)
	if err != nil {
		return nil, err
	}
	if err := u.repo.Update(ctx, w); err != nil {
		return nil, err
	}
	return w, nil
}

func (u *warehouseUseCaseImpl) DeleteWarehouse(ctx context.Context, id uuid.UUID) error {
	return u.repo.Delete(ctx, id)
}
