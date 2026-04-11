package postgres

import (
	"context"
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type paymentRepositoryImpl struct {
	db *pgxpool.Pool
}

func NewPaymentRepository(db *pgxpool.Pool) repository.PaymentRepository {
	return &paymentRepositoryImpl{db: db}
}

func (r *paymentRepositoryImpl) Create(ctx context.Context, p *models.Payment) error {
	if p.ID == uuid.Nil {
		p.ID = uuid.New()
	}
	query := `INSERT INTO payments (id, activity_id, amount, method, reference_no, photo_path) VALUES ($1, $2, $3, $4, $5, $6)`
	_, err := r.db.Exec(ctx, query, p.ID, p.ActivityID, p.Amount, p.Method, p.ReferenceNo, p.PhotoPath)
	return err
}

func (r *paymentRepositoryImpl) GetByActivityID(ctx context.Context, activityID uuid.UUID) (*models.Payment, error) {
	query := `SELECT id, activity_id, amount, method, reference_no, photo_path, created_at FROM payments WHERE activity_id = $1`
	p := &models.Payment{}
	err := r.db.QueryRow(ctx, query, activityID).Scan(
		&p.ID, &p.ActivityID, &p.Amount, &p.Method, &p.ReferenceNo, &p.PhotoPath, &p.CreatedAt,
	)
	if err == pgx.ErrNoRows {
		return nil, nil
	}
	return p, err
}
