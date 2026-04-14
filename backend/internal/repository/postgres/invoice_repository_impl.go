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

type invoiceRepoImpl struct {
	db *pgxpool.Pool
}

func NewInvoiceRepository(db *pgxpool.Pool) repository.InvoiceRepository {
	return &invoiceRepoImpl{db: db}
}

func (r *invoiceRepoImpl) Create(ctx context.Context, inv *models.Invoice) error {
	if inv.ID == uuid.Nil {
		inv.ID = uuid.New()
	}
	
	tx, err := r.db.Begin(ctx)
	if err != nil {
		return err
	}
	defer tx.Rollback(ctx)

	query := `INSERT INTO invoices (id, customer_id, deal_id, invoice_no, amount, paid_amount, status, due_at, signature_path) 
	          VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING created_at, updated_at`
	
	err = tx.QueryRow(ctx, query, inv.ID, inv.CustomerID, inv.DealID, inv.InvoiceNo, inv.Amount, inv.PaidAmount, inv.Status, inv.DueAt, inv.SignaturePath).
		Scan(&inv.CreatedAt, &inv.UpdatedAt)
	if err != nil {
		return err
	}

	for _, item := range inv.Items {
		if item.ID == uuid.Nil {
			item.ID = uuid.New()
		}
		item.InvoiceID = inv.ID
		_, err = tx.Exec(ctx, `INSERT INTO invoice_items (id, invoice_id, product_id, name, quantity, unit, unit_price) 
		                       VALUES ($1, $2, $3, $4, $5, $6, $7)`,
			item.ID, item.InvoiceID, item.ProductID, item.Name, item.Quantity, item.Unit, item.UnitPrice)
		if err != nil {
			return err
		}
	}

	return tx.Commit(ctx)
}

func (r *invoiceRepoImpl) GetByID(ctx context.Context, id uuid.UUID) (*models.Invoice, error) {
	query := `SELECT id, customer_id, deal_id, invoice_no, amount, paid_amount, status, due_at, signature_path, created_at, updated_at 
	          FROM invoices WHERE id = $1`
	
	inv := &models.Invoice{}
	err := r.db.QueryRow(ctx, query, id).Scan(
		&inv.ID, &inv.CustomerID, &inv.DealID, &inv.InvoiceNo, &inv.Amount, &inv.PaidAmount, &inv.Status, &inv.DueAt, &inv.SignaturePath, &inv.CreatedAt, &inv.UpdatedAt,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}

	// Fetch items
	rows, err := r.db.Query(ctx, `SELECT id, invoice_id, product_id, name, quantity, unit, unit_price, subtotal, created_at 
	                              FROM invoice_items WHERE invoice_id = $1`, id)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		item := &models.InvoiceItem{}
		err := rows.Scan(&item.ID, &item.InvoiceID, &item.ProductID, &item.Name, &item.Quantity, &item.Unit, &item.UnitPrice, &item.Subtotal, &item.CreatedAt)
		if err != nil {
			return nil, err
		}
		inv.Items = append(inv.Items, item)
	}

	return inv, nil
}

func (r *invoiceRepoImpl) List(ctx context.Context, filter repository.InvoiceFilter) ([]*models.Invoice, error) {
	baseQuery := `SELECT id, customer_id, deal_id, invoice_no, amount, paid_amount, status, due_at, signature_path, created_at, updated_at FROM invoices`
	var conditions []string
	var args []interface{}
	argCount := 1

	if filter.CustomerID != nil {
		conditions = append(conditions, fmt.Sprintf("customer_id = $%d", argCount))
		args = append(args, *filter.CustomerID)
		argCount++
	}
	if filter.Status != nil {
		conditions = append(conditions, fmt.Sprintf("status = $%d", argCount))
		args = append(args, *filter.Status)
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

	var results []*models.Invoice
	for rows.Next() {
		inv := &models.Invoice{}
		err := rows.Scan(
			&inv.ID, &inv.CustomerID, &inv.DealID, &inv.InvoiceNo, &inv.Amount, &inv.PaidAmount, &inv.Status, &inv.DueAt, &inv.SignaturePath, &inv.CreatedAt, &inv.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		results = append(results, inv)
	}
	return results, nil
}

func (r *invoiceRepoImpl) GetByCustomerID(ctx context.Context, customerID uuid.UUID) ([]*models.Invoice, error) {
	return r.List(ctx, repository.InvoiceFilter{CustomerID: &customerID})
}

func (r *invoiceRepoImpl) UpdateStatus(ctx context.Context, id uuid.UUID, status models.InvoiceStatus) error {
	_, err := r.db.Exec(ctx, `UPDATE invoices SET status = $1, updated_at = NOW() WHERE id = $2`, status, id)
	return err
}

func (r *invoiceRepoImpl) Update(ctx context.Context, inv *models.Invoice) error {
	query := `UPDATE invoices SET status = $1, paid_amount = $2, signature_path = $3, updated_at = NOW() WHERE id = $4`
	_, err := r.db.Exec(ctx, query, inv.Status, inv.PaidAmount, inv.SignaturePath, inv.ID)
	return err
}
