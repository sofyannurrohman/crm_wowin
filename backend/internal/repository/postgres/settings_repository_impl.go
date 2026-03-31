package postgres

import (
	"context"
	"crm_wowin_backend/internal/domain/repository"
	"encoding/json"

	"github.com/jackc/pgx/v5/pgxpool"
)

type settingsRepositoryImpl struct {
	db *pgxpool.Pool
}

func NewSettingsRepository(db *pgxpool.Pool) repository.SettingsRepository {
	return &settingsRepositoryImpl{db: db}
}

func (r *settingsRepositoryImpl) GetAll(ctx context.Context) ([]repository.AppSetting, error) {
	query := `SELECT key, value, description FROM app_settings`
	rows, err := r.db.Query(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var settings []repository.AppSetting
	for rows.Next() {
		var s repository.AppSetting
		var valJSON []byte
		if err := rows.Scan(&s.Key, &valJSON, &s.Description); err != nil {
			return nil, err
		}
		json.Unmarshal(valJSON, &s.Value)
		settings = append(settings, s)
	}
	return settings, nil
}

func (r *settingsRepositoryImpl) GetByKey(ctx context.Context, key string) (*repository.AppSetting, error) {
	query := `SELECT key, value, description FROM app_settings WHERE key = $1`
	var s repository.AppSetting
	var valJSON []byte
	err := r.db.QueryRow(ctx, query, key).Scan(&s.Key, &valJSON, &s.Description)
	if err != nil {
		return nil, err
	}
	json.Unmarshal(valJSON, &s.Value)
	return &s, nil
}

func (r *settingsRepositoryImpl) Update(ctx context.Context, key string, value interface{}, updatedBy string) error {
	valJSON, _ := json.Marshal(value)
	query := `UPDATE app_settings SET value = $1, updated_by = $2, updated_at = NOW() WHERE key = $3`
	_, err := r.db.Exec(ctx, query, valJSON, updatedBy, key)
	return err
}
