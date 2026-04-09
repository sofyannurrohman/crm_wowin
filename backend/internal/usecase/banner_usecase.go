package usecase

import (
	"context"
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"
)

type BannerUseCase interface {
	CreateBanner(ctx context.Context, banner *models.Banner) (*models.Banner, error)
	ListBanners(ctx context.Context, filter repository.BannerFilter) ([]*models.Banner, error)
}

type bannerUseCaseImpl struct {
	repo repository.BannerRepository
}

func NewBannerUseCase(repo repository.BannerRepository) BannerUseCase {
	return &bannerUseCaseImpl{repo: repo}
}

func (u *bannerUseCaseImpl) CreateBanner(ctx context.Context, banner *models.Banner) (*models.Banner, error) {
	err := u.repo.Create(ctx, banner)
	if err != nil {
		return nil, err
	}
	return u.repo.GetByID(ctx, banner.ID)
}

func (u *bannerUseCaseImpl) ListBanners(ctx context.Context, filter repository.BannerFilter) ([]*models.Banner, error) {
	return u.repo.List(ctx, filter)
}
