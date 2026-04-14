package postgres

import (
	"context"
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"
	"fmt"
	"strings"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type stockTransferRepoImpl struct {
	db *pgxpool.Pool
}

func NewStockTransferRepository(db *pgxpool.Pool) repository.StockTransferRepository {
	return &stockTransferRepoImpl{db: db}
}

func (r *stockTransferRepoImpl) Create(ctx context.Context, st *models.StockTransfer) error {
	if st.ID == uuid.Nil {
		st.ID = uuid.New()
	}

	tx, err := r.db.Begin(ctx)
	if err != nil {
		return err
	}
	defer tx.Rollback(ctx)

	query := `INSERT INTO stock_transfers (id, warehouse_id, sales_id, type, status, notes) 
	          VALUES ($1, $2, $3, $4, $5, $6) RETURNING created_at, updated_at`
	
	err = tx.QueryRow(ctx, query, st.ID, st.WarehouseID, st.SalesID, st.Type, st.Status, st.Notes).
		Scan(&st.CreatedAt, &st.UpdatedAt)
	if err != nil {
		return err
	}

	for _, item := range st.Items {
		if item.ID == uuid.Nil {
			item.ID = uuid.New()
		}
		item.TransferID = st.ID
		_, err = tx.Exec(ctx, `INSERT INTO stock_transfer_items (id, transfer_id, product_id, quantity) 
		                       VALUES ($1, $2, $3, $4)`,
			item.ID, item.TransferID, item.ProductID, item.Quantity)
		if err != nil {
			return err
		}
	}

	return tx.Commit(ctx)
}

func (r *stockTransferRepoImpl) GetByID(ctx context.Context, id uuid.UUID) (*models.StockTransfer, error) {
	query := `SELECT id, warehouse_id, sales_id, type, status, notes, created_at, updated_at 
	          FROM stock_transfers WHERE id = $1`
	
	st := &models.StockTransfer{}
	err := r.db.QueryRow(ctx, query, id).Scan(
		&st.ID, &st.WarehouseID, &st.SalesID, &st.Type, &st.Status, &st.Notes, &st.CreatedAt, &st.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}

	// Fetch items
	rows, err := r.db.Query(ctx, `SELECT id, transfer_id, product_id, quantity, created_at 
	                              FROM stock_transfer_items WHERE transfer_id = $1`, id)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		item := &models.StockTransferItem{}
		err := rows.Scan(&item.ID, &item.TransferID, &item.ProductID, &item.Quantity, &item.CreatedAt)
		if err != nil {
			return nil, err
		}
		st.Items = append(st.Items, item)
	}

	return st, nil
}

func (r *stockTransferRepoImpl) List(ctx context.Context, filter repository.StockTransferFilter) ([]*models.StockTransfer, error) {
	baseQuery := `SELECT id, warehouse_id, sales_id, type, status, notes, created_at, updated_at FROM stock_transfers`
	var conditions []string
	var args []interface{}
	argCount := 1

	if filter.SalesID != nil {
		conditions = append(conditions, fmt.Sprintf("sales_id = $%d", argCount))
		args = append(args, *filter.SalesID)
		argCount++
	}
	if filter.WarehouseID != nil {
		conditions = append(conditions, fmt.Sprintf("warehouse_id = $%d", argCount))
		args = append(args, *filter.WarehouseID)
		argCount++
	}
	if filter.Status != nil {
		conditions = append(conditions, fmt.Sprintf("status = $%d", argCount))
		args = append(args, *filter.Status)
		argCount++
	}
	if filter.Type != nil {
		conditions = append(conditions, fmt.Sprintf("type = $%d", argCount))
		args = append(args, *filter.Type)
		argCount++
	}

	if len(conditions) > 0 {
		baseQuery += " WHERE " + strings.Join(conditions, " AND ")
	}
	baseQuery += " ORDER BY created_at DESC"

	rows, err := r.db.Query(ctx, baseQuery, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []*models.StockTransfer
	for rows.Next() {
		st := &models.StockTransfer{}
		err := rows.Scan(
			&st.ID, &st.WarehouseID, &st.SalesID, &st.Type, &st.Status, &st.Notes, &st.CreatedAt, &st.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		results = append(results, st)
	}
	return results, nil
}

func (r *stockTransferRepoImpl) UpdateStatus(ctx context.Context, id uuid.UUID, status models.StockTransferStatus) error {
	_, err := r.db.Exec(ctx, `UPDATE stock_transfers SET status = $1, updated_at = NOW() WHERE id = $2`, status, id)
	return err
}
