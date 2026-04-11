package postgres

import (
	"context"
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"
	"fmt"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type vanStockRepositoryImpl struct {
	db *pgxpool.Pool
}

func NewVanStockRepository(db *pgxpool.Pool) repository.VanStockRepository {
	return &vanStockRepositoryImpl{db: db}
}

func (r *vanStockRepositoryImpl) GetByUser(ctx context.Context, userID uuid.UUID) ([]*models.VanStock, error) {
	query := `
		SELECT vs.id, vs.user_id, vs.product_id, vs.quantity, vs.updated_at,
		       p.name, p.sku, p.price, p.unit
		FROM van_stocks vs
		JOIN products p ON vs.product_id = p.id
		WHERE vs.user_id = $1`
	
	rows, err := r.db.Query(ctx, query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []*models.VanStock
	for rows.Next() {
		vs := &models.VanStock{Product: &models.Product{}}
		err := rows.Scan(
			&vs.ID, &vs.UserID, &vs.ProductID, &vs.Quantity, &vs.UpdatedAt,
			&vs.Product.Name, &vs.Product.SKU, &vs.Product.Price, &vs.Product.Unit,
		)
		if err != nil {
			return nil, err
		}
		vs.Product.ID = vs.ProductID
		results = append(results, vs)
	}
	return results, nil
}

func (r *vanStockRepositoryImpl) GetByUserAndProduct(ctx context.Context, userID, productID uuid.UUID) (*models.VanStock, error) {
	query := `SELECT id, user_id, product_id, quantity, updated_at FROM van_stocks WHERE user_id = $1 AND product_id = $2`
	vs := &models.VanStock{}
	err := r.db.QueryRow(ctx, query, userID, productID).Scan(&vs.ID, &vs.UserID, &vs.ProductID, &vs.Quantity, &vs.UpdatedAt)
	if err == pgx.ErrNoRows {
		return nil, nil
	}
	return vs, err
}

func (r *vanStockRepositoryImpl) Update(ctx context.Context, vs *models.VanStock) error {
	query := `UPDATE van_stocks SET quantity = $1, updated_at = NOW() WHERE id = $2`
	_, err := r.db.Exec(ctx, query, vs.Quantity, vs.ID)
	return err
}

func (r *vanStockRepositoryImpl) Create(ctx context.Context, vs *models.VanStock) error {
	if vs.ID == uuid.Nil {
		vs.ID = uuid.New()
	}
	query := `INSERT INTO van_stocks (id, user_id, product_id, quantity) VALUES ($1, $2, $3, $4)`
	_, err := r.db.Exec(ctx, query, vs.ID, vs.UserID, vs.ProductID, vs.Quantity)
	return err
}

func (r *vanStockRepositoryImpl) DeductStock(ctx context.Context, userID, productID uuid.UUID, quantity float64) error {
	query := `UPDATE van_stocks SET quantity = quantity - $1, updated_at = NOW() WHERE user_id = $2 AND product_id = $3`
	tag, err := r.db.Exec(ctx, query, quantity, userID, productID)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return fmt.Errorf("no stock record found for user %s and product %s", userID, productID)
	}
	return nil
}
