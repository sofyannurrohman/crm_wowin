package postgres

import (
	"context"
	"crm_wowin_backend/internal/domain/dberrors"
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"
	"errors"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type salesTargetRepositoryImpl struct {
	db *pgxpool.Pool
}

func NewSalesTargetRepository(db *pgxpool.Pool) repository.SalesTargetRepository {
	return &salesTargetRepositoryImpl{db: db}
}

func (r *salesTargetRepositoryImpl) GetByUserID(ctx context.Context, userID uuid.UUID, month, year int) (*models.SalesTarget, error) {
	query := `
		SELECT id, user_id, period_year, period_month, target_revenue, target_visits, target_deals, target_new_customers, win_rate, created_at, updated_at
		FROM sales_targets
		WHERE user_id = $1 AND period_month = $2 AND period_year = $3
	`
	var t models.SalesTarget
	err := r.db.QueryRow(ctx, query, userID, month, year).Scan(
		&t.ID, &t.UserID, &t.PeriodYear, &t.PeriodMonth, &t.TargetRevenue, &t.TargetVisits, &t.TargetDeals, &t.TargetNewCustomers, &t.WinRate, &t.CreatedAt, &t.UpdatedAt,
	)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, dberrors.ErrNotFound
		}
		return nil, dberrors.ErrInternalServer
	}
	return &t, nil
}

func (r *salesTargetRepositoryImpl) Upsert(ctx context.Context, t *models.SalesTarget) error {
	query := `
		INSERT INTO sales_targets (user_id, period_year, period_month, target_revenue, target_visits, target_deals, target_new_customers, win_rate, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW())
		ON CONFLICT (user_id, period_year, period_month) DO UPDATE SET
			target_revenue = EXCLUDED.target_revenue,
			target_visits = EXCLUDED.target_visits,
			target_deals = EXCLUDED.target_deals,
			target_new_customers = EXCLUDED.target_new_customers,
			win_rate = EXCLUDED.win_rate,
			updated_at = NOW()
		RETURNING id, created_at, updated_at
	`
	err := r.db.QueryRow(ctx, query,
		t.UserID, t.PeriodYear, t.PeriodMonth, t.TargetRevenue, t.TargetVisits, t.TargetDeals, t.TargetNewCustomers, t.WinRate,
	).Scan(&t.ID, &t.CreatedAt, &t.UpdatedAt)

	if err != nil {
		return dberrors.ErrInternalServer
	}
	return nil
}

func (r *salesTargetRepositoryImpl) FindByUserID(ctx context.Context, userID uuid.UUID) ([]*models.SalesTarget, error) {
	query := `
		SELECT id, user_id, period_year, period_month, target_revenue, target_visits, target_deals, target_new_customers, win_rate, created_at, updated_at
		FROM sales_targets
		WHERE user_id = $1
		ORDER BY period_year DESC, period_month DESC
	`
	rows, err := r.db.Query(ctx, query, userID)
	if err != nil {
		return nil, dberrors.ErrInternalServer
	}
	defer rows.Close()

	var targets []*models.SalesTarget
	for rows.Next() {
		var t models.SalesTarget
		err := rows.Scan(
			&t.ID, &t.UserID, &t.PeriodYear, &t.PeriodMonth, &t.TargetRevenue, &t.TargetVisits, &t.TargetDeals, &t.TargetNewCustomers, &t.WinRate, &t.CreatedAt, &t.UpdatedAt,
		)
		if err != nil {
			return nil, dberrors.ErrInternalServer
		}
		targets = append(targets, &t)
	}
	return targets, nil
}
