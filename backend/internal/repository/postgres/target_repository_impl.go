package postgres

import (
	"context"
	"crm_wowin_backend/internal/domain/dberrors"
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"
	"errors"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type targetRepositoryImpl struct {
	db *pgxpool.Pool
}

func NewTargetRepository(db *pgxpool.Pool) repository.TargetRepository {
	return &targetRepositoryImpl{db: db}
}

func (r *targetRepositoryImpl) Get(ctx context.Context) (*models.Target, error) {
	query := `
		SELECT monthly_revenue, monthly_visits, monthly_new_customers, win_rate, monthly_deals, updated_at
		FROM global_targets
		LIMIT 1
	`
	var t models.Target
	err := r.db.QueryRow(ctx, query).Scan(
		&t.MonthlyRevenue, &t.MonthlyVisits, &t.MonthlyNewCustomers, &t.WinRate, &t.MonthlyDeals, &t.UpdatedAt,
	)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, dberrors.ErrNotFound
		}
		return nil, dberrors.ErrInternalServer
	}
	return &t, nil
}

func (r *targetRepositoryImpl) Upsert(ctx context.Context, t *models.Target) error {
	query := `
		INSERT INTO global_targets (id, monthly_revenue, monthly_visits, monthly_new_customers, win_rate, monthly_deals, updated_at)
		VALUES ((SELECT id FROM global_targets LIMIT 1), $1, $2, $3, $4, $5, NOW())
		ON CONFLICT (id) DO UPDATE SET
			monthly_revenue = EXCLUDED.monthly_revenue,
			monthly_visits = EXCLUDED.monthly_visits,
			monthly_new_customers = EXCLUDED.monthly_new_customers,
			win_rate = EXCLUDED.win_rate,
			monthly_deals = EXCLUDED.monthly_deals,
			updated_at = NOW()
	`
	// If no record exists, generate a new UUID
	// but for simplicity, we assume there's always 1 record due to the migration seed
	_, err := r.db.Exec(ctx, query, t.MonthlyRevenue, t.MonthlyVisits, t.MonthlyNewCustomers, t.WinRate, t.MonthlyDeals)
	if err != nil {
		return dberrors.ErrInternalServer
	}
	return nil
}
