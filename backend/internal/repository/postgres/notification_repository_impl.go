package postgres

import (
	"context"
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
)

type notificationRepositoryImpl struct {
	db *pgxpool.Pool
}

func NewNotificationRepository(db *pgxpool.Pool) repository.NotificationRepository {
	return &notificationRepositoryImpl{db: db}
}

func (r *notificationRepositoryImpl) Create(ctx context.Context, n *models.Notification) error {
	query := `
		INSERT INTO notifications (user_id, type, title, body, entity_type, entity_id)
		VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING id, created_at
	`
	return r.db.QueryRow(ctx, query, n.UserID, n.Type, n.Title, n.Body, n.EntityType, n.EntityID).
		Scan(&n.ID, &n.CreatedAt)
}

func (r *notificationRepositoryImpl) GetByID(ctx context.Context, id uuid.UUID) (*models.Notification, error) {
	query := `
		SELECT id, user_id, type, title, body, entity_type, entity_id, is_read, read_at, sent_at, created_at
		FROM notifications WHERE id = $1
	`
	var n models.Notification
	err := r.db.QueryRow(ctx, query, id).Scan(
		&n.ID, &n.UserID, &n.Type, &n.Title, &n.Body, &n.EntityType, &n.EntityID, &n.IsRead, &n.ReadAt, &n.SentAt, &n.CreatedAt,
	)
	if err != nil {
		return nil, err
	}
	return &n, nil
}

func (r *notificationRepositoryImpl) ListByUser(ctx context.Context, userID uuid.UUID, limit, offset int) ([]models.Notification, error) {
	query := `
		SELECT id, user_id, type, title, body, entity_type, entity_id, is_read, read_at, sent_at, created_at
		FROM notifications
		WHERE user_id = $1
		ORDER BY created_at DESC
		LIMIT $2 OFFSET $3
	`
	rows, err := r.db.Query(ctx, query, userID, limit, offset)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []models.Notification
	for rows.Next() {
		var n models.Notification
		err := rows.Scan(&n.ID, &n.UserID, &n.Type, &n.Title, &n.Body, &n.EntityType, &n.EntityID, &n.IsRead, &n.ReadAt, &n.SentAt, &n.CreatedAt)
		if err != nil {
			return nil, err
		}
		results = append(results, n)
	}
	return results, nil
}

func (r *notificationRepositoryImpl) MarkAsRead(ctx context.Context, id uuid.UUID) error {
	query := `UPDATE notifications SET is_read = TRUE, read_at = NOW() WHERE id = $1`
	_, err := r.db.Exec(ctx, query, id)
	return err
}

func (r *notificationRepositoryImpl) MarkAllAsRead(ctx context.Context, userID uuid.UUID) error {
	query := `UPDATE notifications SET is_read = TRUE, read_at = NOW() WHERE user_id = $1 AND is_read = FALSE`
	_, err := r.db.Exec(ctx, query, userID)
	return err
}

func (r *notificationRepositoryImpl) GetUnreadCount(ctx context.Context, userID uuid.UUID) (int, error) {
	query := `SELECT COUNT(*) FROM notifications WHERE user_id = $1 AND is_read = FALSE`
	var count int
	err := r.db.QueryRow(ctx, query, userID).Scan(&count)
	return count, err
}
