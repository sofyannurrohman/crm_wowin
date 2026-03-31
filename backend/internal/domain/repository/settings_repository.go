package repository

import (
	"context"
)

type AppSetting struct {
	Key         string      `json:"key"`
	Value       interface{} `json:"value"`
	Description string      `json:"description"`
}

type SettingsRepository interface {
	GetAll(ctx context.Context) ([]AppSetting, error)
	GetByKey(ctx context.Context, key string) (*AppSetting, error)
	Update(ctx context.Context, key string, value interface{}, updatedBy string) error
}
