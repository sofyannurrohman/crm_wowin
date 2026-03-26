package postgres

import (
	"context"
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"
	"encoding/json"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
)

type territoryRepositoryImpl struct {
	db *pgxpool.Pool
}

func NewTerritoryRepository(db *pgxpool.Pool) repository.TerritoryRepository {
	return &territoryRepositoryImpl{db: db}
}

func (r *territoryRepositoryImpl) Create(ctx context.Context, t *models.Territory) error {
	geomJSON, _ := json.Marshal(t.Geometry)
	query := `
		INSERT INTO territories (name, description, geom, color, status, created_by)
		VALUES ($1, $2, ST_GeomFromGeoJSON($3), $4, $5, $6)
		RETURNING id, created_at, updated_at
	`
	return r.db.QueryRow(ctx, query, t.Name, t.Description, string(geomJSON), t.Color, t.Status, t.CreatedBy).
		Scan(&t.ID, &t.CreatedAt, &t.UpdatedAt)
}

func (r *territoryRepositoryImpl) GetByID(ctx context.Context, id uuid.UUID) (*models.Territory, error) {
	query := `
		SELECT id, name, description, ST_AsGeoJSON(geom), color, status, created_by, created_at, updated_at
		FROM territories WHERE id = $1
	`
	var t models.Territory
	var geomStr string
	err := r.db.QueryRow(ctx, query, id).Scan(
		&t.ID, &t.Name, &t.Description, &geomStr, &t.Color, &t.Status, &t.CreatedBy, &t.CreatedAt, &t.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}
	json.Unmarshal([]byte(geomStr), &t.Geometry)
	return &t, nil
}

func (r *territoryRepositoryImpl) List(ctx context.Context) ([]*models.Territory, error) {
	query := `
		SELECT id, name, description, ST_AsGeoJSON(geom), color, status, created_by, created_at, updated_at
		FROM territories ORDER BY created_at DESC
	`
	rows, err := r.db.Query(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []*models.Territory
	for rows.Next() {
		var t models.Territory
		var geomStr string
		err := rows.Scan(&t.ID, &t.Name, &t.Description, &geomStr, &t.Color, &t.Status, &t.CreatedBy, &t.CreatedAt, &t.UpdatedAt)
		if err != nil {
			return nil, err
		}
		json.Unmarshal([]byte(geomStr), &t.Geometry)
		results = append(results, &t)
	}
	return results, nil
}

func (r *territoryRepositoryImpl) Update(ctx context.Context, t *models.Territory) error {
	geomJSON, _ := json.Marshal(t.Geometry)
	query := `
		UPDATE territories 
		SET name = $1, description = $2, geom = ST_GeomFromGeoJSON($3), color = $4, status = $5, updated_at = NOW()
		WHERE id = $6
	`
	_, err := r.db.Exec(ctx, query, t.Name, t.Description, string(geomJSON), t.Color, t.Status, t.ID)
	return err
}

func (r *territoryRepositoryImpl) Delete(ctx context.Context, id uuid.UUID) error {
	query := `DELETE FROM territories WHERE id = $1`
	_, err := r.db.Exec(ctx, query, id)
	return err
}

func (r *territoryRepositoryImpl) AssignUser(ctx context.Context, territoryID, userID, assignedBy uuid.UUID) error {
	query := `
		INSERT INTO territory_users (territory_id, user_id, assigned_by)
		VALUES ($1, $2, $3)
		ON CONFLICT DO NOTHING
	`
	_, err := r.db.Exec(ctx, query, territoryID, userID, assignedBy)
	return err
}

func (r *territoryRepositoryImpl) UnassignUser(ctx context.Context, territoryID, userID uuid.UUID) error {
	query := `DELETE FROM territory_users WHERE territory_id = $1 AND user_id = $2`
	_, err := r.db.Exec(ctx, query, territoryID, userID)
	return err
}

func (r *territoryRepositoryImpl) ListUsers(ctx context.Context, territoryID uuid.UUID) ([]uuid.UUID, error) {
	query := `SELECT user_id FROM territory_users WHERE territory_id = $1`
	rows, err := r.db.Query(ctx, query, territoryID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var ids []uuid.UUID
	for rows.Next() {
		var id uuid.UUID
		if err := rows.Scan(&id); err != nil {
			return nil, err
		}
		ids = append(ids, id)
	}
	return ids, nil
}
