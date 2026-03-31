package postgres

import (
	"context"
	"crm_wowin_backend/internal/domain/dberrors"
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"
	"errors"
	"fmt"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type productRepoImpl struct {
	db *pgxpool.Pool
}

func NewProductRepository(db *pgxpool.Pool) repository.ProductRepository {
	return &productRepoImpl{db: db}
}

func (r *productRepoImpl) CreateCategory(ctx context.Context, c *models.ProductCategory) error {
	query := `INSERT INTO product_categories (name, parent_id)
			  VALUES ($1, $2) RETURNING id, created_at`
	err := r.db.QueryRow(ctx, query, c.Name, c.ParentID).Scan(&c.ID, &c.CreatedAt)
	return err
}

func (r *productRepoImpl) GetCategoryByID(ctx context.Context, id uuid.UUID) (*models.ProductCategory, error) {
	query := `SELECT id, name, parent_id, created_at FROM product_categories WHERE id=$1`
	var c models.ProductCategory
	err := r.db.QueryRow(ctx, query, id).Scan(&c.ID, &c.Name, &c.ParentID, &c.CreatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, dberrors.ErrNotFound
	}
	return &c, err
}

func (r *productRepoImpl) ListCategories(ctx context.Context) ([]*models.ProductCategory, error) {
	query := `SELECT id, name, parent_id, created_at FROM product_categories ORDER BY name ASC`
	rows, err := r.db.Query(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []*models.ProductCategory
	for rows.Next() {
		var c models.ProductCategory
		err := rows.Scan(&c.ID, &c.Name, &c.ParentID, &c.CreatedAt)
		if err != nil {
			return nil, err
		}
		results = append(results, &c)
	}
	return results, nil
}

func (r *productRepoImpl) UpdateCategory(ctx context.Context, c *models.ProductCategory) error {
	query := `UPDATE product_categories SET name=$1, parent_id=$2 WHERE id=$3`
	_, err := r.db.Exec(ctx, query, c.Name, c.ParentID, c.ID)
	if errors.Is(err, pgx.ErrNoRows) {
		return dberrors.ErrNotFound
	}
	return err
}

// === Products ===

func (r *productRepoImpl) Create(ctx context.Context, p *models.Product) error {
	query := `INSERT INTO products (category_id, code, name, description, unit, base_price, is_active)
			  VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING id, created_at, updated_at`
	err := r.db.QueryRow(ctx, query, p.CategoryID, p.SKU, p.Name, p.Description, p.Unit, p.Price, p.IsActive).
		Scan(&p.ID, &p.CreatedAt, &p.UpdatedAt)
	return err
}

func (r *productRepoImpl) GetByID(ctx context.Context, id uuid.UUID) (*models.Product, error) {
	query := `SELECT id, category_id, code, name, description, unit, base_price, is_active, created_at, updated_at 
			  FROM products WHERE id=$1`
	var p models.Product
	err := r.db.QueryRow(ctx, query, id).Scan(
		&p.ID, &p.CategoryID, &p.SKU, &p.Name, &p.Description, &p.Unit, &p.Price, &p.IsActive, &p.CreatedAt, &p.UpdatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, dberrors.ErrNotFound
	}
	return &p, err
}

func (r *productRepoImpl) List(ctx context.Context, filter repository.ProductFilter) ([]*models.Product, error) {
	baseQuery := `SELECT id, category_id, code, name, description, unit, base_price, is_active, created_at FROM products WHERE 1=1 `
	args := []interface{}{}
	argCount := 1

	if filter.CategoryID != nil {
		baseQuery += fmt.Sprintf(" AND category_id = $%d", argCount)
		args = append(args, *filter.CategoryID)
		argCount++
	}
	if filter.Search != "" {
		baseQuery += fmt.Sprintf(" AND (name ILIKE $%d OR code ILIKE $%d)", argCount, argCount+1)
		args = append(args, "%"+filter.Search+"%", "%"+filter.Search+"%")
		argCount += 2
	}
	if filter.IsActive != nil {
		baseQuery += fmt.Sprintf(" AND is_active = $%d", argCount)
		args = append(args, *filter.IsActive)
	}

	baseQuery += " ORDER BY name ASC"

	rows, err := r.db.Query(ctx, baseQuery, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []*models.Product
	for rows.Next() {
		var p models.Product
		err := rows.Scan(&p.ID, &p.CategoryID, &p.SKU, &p.Name, &p.Description, &p.Unit, &p.Price, &p.IsActive, &p.CreatedAt)
		if err != nil {
			return nil, err
		}
		results = append(results, &p)
	}
	return results, nil
}

func (r *productRepoImpl) Update(ctx context.Context, p *models.Product) error {
	query := `UPDATE products SET category_id=$1, code=$2, name=$3, description=$4, unit=$5, base_price=$6, is_active=$7, updated_at=NOW() 
			  WHERE id=$8 RETURNING updated_at`
	err := r.db.QueryRow(ctx, query, p.CategoryID, p.SKU, p.Name, p.Description, p.Unit, p.Price, p.IsActive, p.ID).Scan(&p.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return dberrors.ErrNotFound
	}
	return err
}

func (r *productRepoImpl) Delete(ctx context.Context, id uuid.UUID) error {
	res, err := r.db.Exec(ctx, "DELETE FROM products WHERE id=$1", id)
	if err != nil {
		return err
	}
	if res.RowsAffected() == 0 {
		return dberrors.ErrNotFound
	}
	return nil
}

// === Deal Items ===
type dealItemRepoImpl struct {
	db *pgxpool.Pool
}

func NewDealItemRepository(db *pgxpool.Pool) repository.DealItemRepository {
	return &dealItemRepoImpl{db: db}
}


func (r *dealItemRepoImpl) AddItem(ctx context.Context, item *models.DealItem) error {
	query := `INSERT INTO deal_items (deal_id, product_id, quantity, unit_price, discount, notes)
			  VALUES ($1, $2, $3, $4, $5, $6) RETURNING id, subtotal, created_at`
	// db trigger calculates subtotal
	err := r.db.QueryRow(ctx, query, item.DealID, item.ProductID, item.Quantity, item.UnitPrice, item.Discount, item.Notes).
		Scan(&item.ID, &item.Subtotal, &item.CreatedAt)
	return err
}

func (r *dealItemRepoImpl) GetItemsByDealID(ctx context.Context, dealID uuid.UUID) ([]*models.DealItem, error) {
	query := `SELECT id, deal_id, product_id, quantity, unit_price, discount, subtotal, notes, created_at 
			  FROM deal_items WHERE deal_id=$1 ORDER BY created_at ASC`
	rows, err := r.db.Query(ctx, query, dealID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []*models.DealItem
	for rows.Next() {
		var i models.DealItem
		err := rows.Scan(&i.ID, &i.DealID, &i.ProductID, &i.Quantity, &i.UnitPrice, &i.Discount, &i.Subtotal, &i.Notes, &i.CreatedAt)
		if err != nil {
			return nil, err
		}
		results = append(results, &i)
	}
	return results, nil
}

func (r *dealItemRepoImpl) GetItemByID(ctx context.Context, id uuid.UUID) (*models.DealItem, error) {
	query := `SELECT id, deal_id, product_id, quantity, unit_price, discount, subtotal, notes, created_at FROM deal_items WHERE id=$1`
	var i models.DealItem
	err := r.db.QueryRow(ctx, query, id).Scan(&i.ID, &i.DealID, &i.ProductID, &i.Quantity, &i.UnitPrice, &i.Discount, &i.Subtotal, &i.Notes, &i.CreatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, dberrors.ErrNotFound
	}
	return &i, err
}

func (r *dealItemRepoImpl) UpdateItem(ctx context.Context, item *models.DealItem) error {
	query := `UPDATE deal_items SET quantity=$1, unit_price=$2, discount=$3, notes=$4 
			  WHERE id=$5 RETURNING subtotal`
	err := r.db.QueryRow(ctx, query, item.Quantity, item.UnitPrice, item.Discount, item.Notes, item.ID).Scan(&item.Subtotal)
	if errors.Is(err, pgx.ErrNoRows) {
		return dberrors.ErrNotFound
	}
	return err
}

func (r *dealItemRepoImpl) RemoveItem(ctx context.Context, itemID uuid.UUID) error {
	res, err := r.db.Exec(ctx, "DELETE FROM deal_items WHERE id=$1", itemID)
	if err != nil {
		return err
	}
	if res.RowsAffected() == 0 {
		return dberrors.ErrNotFound
	}
	return nil
}

func (r *dealItemRepoImpl) SyncDealAmount(ctx context.Context, dealID uuid.UUID) error {
	// Optional enforcement. The Postgres Trigger trg_update_deal_amount handles this automatically on INSERT/UPDATE/DELETE.
	// But giving code visibility helps.
	_, err := r.db.Exec(ctx, "SELECT fn_calculate_deal_amount($1)", dealID)
	return err
}
