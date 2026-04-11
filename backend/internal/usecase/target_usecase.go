package usecase

import (
	"context"
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"

	"github.com/google/uuid"
)

type TargetUseCase interface {
	Get(ctx context.Context) (*models.Target, error)
	Update(ctx context.Context, target *models.Target) error

	// Individual targets
	GetForUser(ctx context.Context, userID uuid.UUID, month, year int) (*models.SalesTarget, error)
	UpdateForUser(ctx context.Context, target *models.SalesTarget) error
	GetAllForUser(ctx context.Context, userID uuid.UUID) ([]*models.SalesTarget, error)
}

type targetUseCaseImpl struct {
	repo            repository.TargetRepository
	salesTargetRepo repository.SalesTargetRepository
}

func NewTargetUseCase(repo repository.TargetRepository, salesTargetRepo repository.SalesTargetRepository) TargetUseCase {
	return &targetUseCaseImpl{repo: repo, salesTargetRepo: salesTargetRepo}
}

func (u *targetUseCaseImpl) Get(ctx context.Context) (*models.Target, error) {
	return u.repo.Get(ctx)
}

func (u *targetUseCaseImpl) Update(ctx context.Context, t *models.Target) error {
	return u.repo.Upsert(ctx, t)
}

func (u *targetUseCaseImpl) GetForUser(ctx context.Context, userID uuid.UUID, month, year int) (*models.SalesTarget, error) {
	return u.salesTargetRepo.GetByUserID(ctx, userID, month, year)
}

func (u *targetUseCaseImpl) UpdateForUser(ctx context.Context, t *models.SalesTarget) error {
	return u.salesTargetRepo.Upsert(ctx, t)
}

func (u *targetUseCaseImpl) GetAllForUser(ctx context.Context, userID uuid.UUID) ([]*models.SalesTarget, error) {
	return u.salesTargetRepo.FindByUserID(ctx, userID)
}
