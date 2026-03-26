package usecase

import (
	"context"
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"

	"github.com/google/uuid"
)

type TerritoryUseCase interface {
	CreateTerritory(ctx context.Context, t *models.Territory) (*models.Territory, error)
	GetTerritory(ctx context.Context, id uuid.UUID) (*models.Territory, error)
	ListTerritories(ctx context.Context) ([]*models.Territory, error)
	UpdateTerritory(ctx context.Context, t *models.Territory) (*models.Territory, error)
	DeleteTerritory(ctx context.Context, id uuid.UUID) error
}

type territoryUseCaseImpl struct {
	repo repository.TerritoryRepository
}

func NewTerritoryUseCase(repo repository.TerritoryRepository) TerritoryUseCase {
	return &territoryUseCaseImpl{repo: repo}
}

func (u *territoryUseCaseImpl) CreateTerritory(ctx context.Context, t *models.Territory) (*models.Territory, error) {
	if t.Status == "" {
		t.Status = models.TerritoryStatusActive
	}
	err := u.repo.Create(ctx, t)
	return t, err
}

func (u *territoryUseCaseImpl) GetTerritory(ctx context.Context, id uuid.UUID) (*models.Territory, error) {
	return u.repo.GetByID(ctx, id)
}

func (u *territoryUseCaseImpl) ListTerritories(ctx context.Context) ([]*models.Territory, error) {
	return u.repo.List(ctx)
}

func (u *territoryUseCaseImpl) UpdateTerritory(ctx context.Context, t *models.Territory) (*models.Territory, error) {
	err := u.repo.Update(ctx, t)
	return t, err
}

func (u *territoryUseCaseImpl) DeleteTerritory(ctx context.Context, id uuid.UUID) error {
	return u.repo.Delete(ctx, id)
}
