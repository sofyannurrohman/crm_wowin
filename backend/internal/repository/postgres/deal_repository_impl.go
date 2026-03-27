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

type dealRepoImpl struct {
	db *pgxpool.Pool
}

func NewDealRepository(db *pgxpool.Pool) repository.DealRepository {
	return &dealRepoImpl{db: db}
}

func (r *dealRepoImpl) Create(ctx context.Context, d *models.Deal) error {
	query := `
		INSERT INTO deals (
			title, customer_id, contact_id, assigned_to, stage, status, 
			amount, probability, expected_close, description, created_by
		) VALUES (
			$1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11
		) RETURNING id, created_at, updated_at
	`
	err := r.db.QueryRow(ctx, query,
		d.Title, d.CustomerID, d.ContactID, d.AssignedTo, d.Stage, d.Status,
		d.Amount, d.Probability, d.ExpectedClose, d.Description, d.CreatedBy,
	).Scan(&d.ID, &d.CreatedAt, &d.UpdatedAt)

	if err != nil {
		return err
	}
	return nil
}

func (r *dealRepoImpl) GetByID(ctx context.Context, id uuid.UUID) (*models.Deal, error) {
	query := `
		SELECT 	id, title, customer_id, contact_id, assigned_to, stage, status, amount, 
				probability, expected_close, closed_at, lost_reason, description, 
				created_by, created_at, updated_at
		FROM deals WHERE id = $1
	`
	var d models.Deal
	err := r.db.QueryRow(ctx, query, id).Scan(
		&d.ID, &d.Title, &d.CustomerID, &d.ContactID, &d.AssignedTo, &d.Stage, &d.Status, &d.Amount,
		&d.Probability, &d.ExpectedClose, &d.ClosedAt, &d.LostReason, &d.Description,
		&d.CreatedBy, &d.CreatedAt, &d.UpdatedAt,
	)

	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, dberrors.ErrNotFound
		}
		return nil, err
	}
	return &d, nil
}

func (r *dealRepoImpl) List(ctx context.Context, filter repository.DealFilter) ([]*models.Deal, error) {
	baseQuery := `SELECT id, title, customer_id, contact_id, assigned_to, stage, status, amount, 
				probability, expected_close, closed_at, created_by, created_at FROM deals WHERE 1=1 `
	
	args := []interface{}{}
	argCount := 1

	if filter.CustomerID != nil {
		baseQuery += fmt.Sprintf(" AND customer_id = $%d", argCount)
		args = append(args, *filter.CustomerID)
		argCount++
	}
	if filter.AssignedTo != nil {
		baseQuery += fmt.Sprintf(" AND assigned_to = $%d", argCount)
		args = append(args, *filter.AssignedTo)
		argCount++
	}
	if filter.Stage != "" {
		baseQuery += fmt.Sprintf(" AND stage = $%d", argCount)
		args = append(args, filter.Stage)
		argCount++
	}
	if filter.Status != "" {
		baseQuery += fmt.Sprintf(" AND status = $%d", argCount)
		args = append(args, filter.Status)
		argCount++
	}
	
	baseQuery += " ORDER BY created_at DESC"

	rows, err := r.db.Query(ctx, baseQuery, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []*models.Deal
	for rows.Next() {
		var d models.Deal
		err := rows.Scan(
			&d.ID, &d.Title, &d.CustomerID, &d.ContactID, &d.AssignedTo, &d.Stage, &d.Status, &d.Amount,
			&d.Probability, &d.ExpectedClose, &d.ClosedAt, &d.CreatedBy, &d.CreatedAt,
		)
		if err != nil {
			return nil, err
		}
		results = append(results, &d)
	}
	return results, nil
}

func (r *dealRepoImpl) Update(ctx context.Context, d *models.Deal) error {
	query := `
		UPDATE deals SET
			title = $1, customer_id = $2, contact_id = $3, assigned_to = $4,
			status = $5, amount = $6, probability = $7, expected_close = $8,
			closed_at = $9, lost_reason = $10, description = $11, updated_at = NOW()
		WHERE id = $12
		RETURNING updated_at
	`
	err := r.db.QueryRow(ctx, query,
		d.Title, d.CustomerID, d.ContactID, d.AssignedTo, d.Status,
		d.Amount, d.Probability, d.ExpectedClose, d.ClosedAt, d.LostReason, d.Description, d.ID,
	).Scan(&d.UpdatedAt)

	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return dberrors.ErrNotFound
		}
		return err
	}
	return nil
}

// UpdateStage handles the explicit transition mechanics (Kanban Drop) and generates trails
func (r *dealRepoImpl) UpdateStage(ctx context.Context, dealID uuid.UUID, newStage models.DealStage, changedBy *uuid.UUID, notes *string) error {
	// First fetch the old stage to record appropriately
	var oldStage models.DealStage
	err := r.db.QueryRow(ctx, "SELECT stage FROM deals WHERE id = $1 FOR UPDATE", dealID).Scan(&oldStage)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return dberrors.ErrNotFound
		}
		return err
	}

	// Begin Transaction to ensure synchronization between Update & History inserts
	tx, err := r.db.Begin(ctx)
	if err != nil {
		return err
	}
	defer tx.Rollback(ctx)

	// Shift Stage in Deals Table
	_, err = tx.Exec(ctx, "UPDATE deals SET stage = $1, updated_at = NOW() WHERE id = $2", newStage, dealID)
	if err != nil {
		return err
	}

	// Dump trail audit
	historyQuery := `
		INSERT INTO deal_stage_history (deal_id, from_stage, to_stage, changed_by, notes)
		VALUES ($1, $2, $3, $4, $5)
	`
	_, err = tx.Exec(ctx, historyQuery, dealID, oldStage, newStage, changedBy, notes)
	if err != nil {
		return err
	}

	return tx.Commit(ctx)
}

func (r *dealRepoImpl) GetStageHistory(ctx context.Context, dealID uuid.UUID) ([]*models.DealStageHistory, error) {
	query := `
		SELECT id, deal_id, from_stage, to_stage, changed_by, notes, changed_at
		FROM deal_stage_history WHERE deal_id = $1 ORDER BY changed_at DESC
	`
	rows, err := r.db.Query(ctx, query, dealID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var history []*models.DealStageHistory
	for rows.Next() {
		var h models.DealStageHistory
		err := rows.Scan(&h.ID, &h.DealID, &h.FromStage, &h.ToStage, &h.ChangedBy, &h.Notes, &h.ChangedAt)
		if err != nil {
			return nil, err
		}
		history = append(history, &h)
	}
	return history, nil
}


// ===============
// LEAD REPOSITORY
// ===============

type leadRepoImpl struct {
	db *pgxpool.Pool
}

func NewLeadRepository(db *pgxpool.Pool) repository.LeadRepository {
	return &leadRepoImpl{db: db}
}

func (r *leadRepoImpl) Create(ctx context.Context, l *models.Lead) error {
	query := `
		INSERT INTO leads (
			title, name, company, email, phone, source, status, 
			assigned_to, estimated_value, notes, created_by
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
		RETURNING id, created_at, updated_at
	`
	err := r.db.QueryRow(ctx, query,
		l.Title, l.Name, l.Company, l.Email, l.Phone, l.Source, l.Status,
		l.AssignedTo, l.EstimatedValue, l.Notes, l.CreatedBy,
	).Scan(&l.ID, &l.CreatedAt, &l.UpdatedAt)

	return err
}

func (r *leadRepoImpl) GetByID(ctx context.Context, id uuid.UUID) (*models.Lead, error) {
	query := `
		SELECT id, title, name, company, email, phone, source, status, assigned_to, 
		customer_id, estimated_value, notes, converted_at, created_by, created_at, updated_at
		FROM leads WHERE id = $1
	`
	var l models.Lead
	err := r.db.QueryRow(ctx, query, id).Scan(
		&l.ID, &l.Title, &l.Name, &l.Company, &l.Email, &l.Phone, &l.Source, &l.Status, &l.AssignedTo,
		&l.CustomerID, &l.EstimatedValue, &l.Notes, &l.ConvertedAt, &l.CreatedBy, &l.CreatedAt, &l.UpdatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, dberrors.ErrNotFound
	}
	return &l, err
}

func (r *leadRepoImpl) List(ctx context.Context, filter repository.LeadFilter) ([]*models.Lead, error) {
	baseQuery := `SELECT id, title, name, company, email, phone, status, source, assigned_to, created_at FROM leads WHERE 1=1 `
	args := []interface{}{}
	argCount := 1

	if filter.Search != "" {
		baseQuery += fmt.Sprintf(" AND (name ILIKE $%d OR company ILIKE $%d)", argCount, argCount+1)
		args = append(args, "%"+filter.Search+"%", "%"+filter.Search+"%")
		argCount += 2
	}
	if filter.Status != "" {
		baseQuery += fmt.Sprintf(" AND status = $%d", argCount)
		args = append(args, filter.Status)
		argCount++
	}
	if filter.AssignedTo != nil {
		baseQuery += fmt.Sprintf(" AND assigned_to = $%d", argCount)
		args = append(args, *filter.AssignedTo)
	}

	baseQuery += " ORDER BY created_at DESC"

	rows, err := r.db.Query(ctx, baseQuery, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []*models.Lead
	for rows.Next() {
		var l models.Lead
		err := rows.Scan(
			&l.ID, &l.Title, &l.Name, &l.Company, &l.Email, &l.Phone, &l.Status, &l.Source, &l.AssignedTo, &l.CreatedAt,
		)
		if err != nil {
			return nil, err
		}
		results = append(results, &l)
	}
	return results, nil
}

func (r *leadRepoImpl) Update(ctx context.Context, l *models.Lead) error {
	query := `
		UPDATE leads SET
			title=$1, name=$2, company=$3, email=$4, phone=$5, source=$6, status=$7, 
			assigned_to=$8, estimated_value=$9, notes=$10, updated_at=NOW()
		WHERE id=$11 RETURNING updated_at
	`
	err := r.db.QueryRow(ctx, query,
		l.Title, l.Name, l.Company, l.Email, l.Phone, l.Source, l.Status,
		l.AssignedTo, l.EstimatedValue, l.Notes, l.ID,
	).Scan(&l.UpdatedAt)
	
	if errors.Is(err, pgx.ErrNoRows) {
		return dberrors.ErrNotFound
	}
	return err
}

func (r *leadRepoImpl) Delete(ctx context.Context, id uuid.UUID) error {
	cmd, err := r.db.Exec(ctx, "DELETE FROM leads WHERE id=$1", id)
	if err != nil {
		return err
	}
	if cmd.RowsAffected() == 0 {
		return dberrors.ErrNotFound
	}
	return nil
}
