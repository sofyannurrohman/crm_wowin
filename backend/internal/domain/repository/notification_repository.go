package repository

import (
	"context"
	"crm_wowin_backend/internal/domain/models"

	"github.com/google/uuid"
)

type NotificationRepository interface {
	Create(ctx context.Context, notification *models.Notification) error
	GetByID(ctx context.Context, id uuid.UUID) (*models.Notification, error)
	ListByUser(ctx context.Context, userID uuid.UUID, limit, offset int) ([]models.Notification, error)
	MarkAsRead(ctx context.Context, id uuid.UUID) error
	MarkAllAsRead(ctx context.Context, userID uuid.UUID) error
	GetUnreadCount(ctx context.Context, userID uuid.UUID) (int, error)
}
