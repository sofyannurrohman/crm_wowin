package usecase

import (
	"context"
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"
)

type TargetUseCase interface {
	Get(ctx context.Context) (*models.Target, error)
	Update(ctx context.Context, target *models.Target) error
}

type targetUseCaseImpl struct {
	repo repository.TargetRepository
}

func NewTargetUseCase(repo repository.TargetRepository) TargetUseCase {
	return &targetUseCaseImpl{repo: repo}
}

func (u *targetUseCaseImpl) Get(ctx context.Context) (*models.Target, error) {
	return u.repo.Get(ctx)
}

func (u *targetUseCaseImpl) Update(ctx context.Context, t *models.Target) error {
	return u.repo.Upsert(ctx, t)
}
