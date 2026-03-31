package usecase

import (
	"context"
	"crm_wowin_backend/internal/domain/repository"
)

type SettingsUseCase interface {
	GetSettings(ctx context.Context) (map[string]interface{}, error)
	UpdateSetting(ctx context.Context, key string, value interface{}, userID string) error
}

type settingsUseCaseImpl struct {
	repo repository.SettingsRepository
}

func NewSettingsUseCase(repo repository.SettingsRepository) SettingsUseCase {
	return &settingsUseCaseImpl{repo: repo}
}

func (u *settingsUseCaseImpl) GetSettings(ctx context.Context) (map[string]interface{}, error) {
	settings, err := u.repo.GetAll(ctx)
	if err != nil {
		return nil, err
	}

	res := make(map[string]interface{})
	for _, s := range settings {
		res[s.Key] = s.Value
	}
	return res, nil
}

func (u *settingsUseCaseImpl) UpdateSetting(ctx context.Context, key string, value interface{}, userID string) error {
	return u.repo.Update(ctx, key, value, userID)
}
