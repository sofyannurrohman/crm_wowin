package postgres

import (
	"context"
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
)

type warehouseRepoImpl struct {
	db *pgxpool.Pool
}

func NewWarehouseRepository(db *pgxpool.Pool) repository.WarehouseRepository {
	return &warehouseRepoImpl{db: db}
}

func (r *warehouseRepoImpl) Create(ctx context.Context, w *models.Warehouse) error {
	query := `INSERT INTO warehouses (name, address, latitude, longitude) 
	          VALUES ($1, $2, $3, $4) RETURNING id, created_at, updated_at`
	return r.db.QueryRow(ctx, query, w.Name, w.Address, w.Latitude, w.Longitude).
		Scan(&w.ID, &w.CreatedAt, &w.UpdatedAt)
}

func (r *warehouseRepoImpl) GetByID(ctx context.Context, id uuid.UUID) (*models.Warehouse, error) {
	query := `SELECT id, name, address, latitude, longitude, created_at, updated_at 
	          FROM warehouses WHERE id = $1`
	var w models.Warehouse
	err := r.db.QueryRow(ctx, query, id).Scan(&w.ID, &w.Name, &w.Address, &w.Latitude, &w.Longitude, &w.CreatedAt, &w.UpdatedAt)
	if err != nil {
		return nil, err
	}
	return &w, nil
}

func (r *warehouseRepoImpl) List(ctx context.Context) ([]*models.Warehouse, error) {
	query := `SELECT id, name, address, latitude, longitude, created_at, updated_at 
	          FROM warehouses ORDER BY name ASC`
	rows, err := r.db.Query(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var warehouses []*models.Warehouse
	for rows.Next() {
		var w models.Warehouse
		if err := rows.Scan(&w.ID, &w.Name, &w.Address, &w.Latitude, &w.Longitude, &w.CreatedAt, &w.UpdatedAt); err != nil {
			return nil, err
		}
		warehouses = append(warehouses, &w)
	}
	return warehouses, nil
}

func (r *warehouseRepoImpl) Update(ctx context.Context, w *models.Warehouse) error {
	query := `UPDATE warehouses SET name=$1, address=$2, latitude=$3, longitude=$4, updated_at=NOW() 
	          WHERE id=$5 RETURNING updated_at`
	return r.db.QueryRow(ctx, query, w.Name, w.Address, w.Latitude, w.Longitude, w.ID).
		Scan(&w.UpdatedAt)
}

func (r *warehouseRepoImpl) Delete(ctx context.Context, id uuid.UUID) error {
	_, err := r.db.Exec(ctx, `DELETE FROM warehouses WHERE id=$1`, id)
	return err
}
