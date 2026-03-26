package usecase

import (
	"context"
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"

	"github.com/google/uuid"
)

type NotificationUseCase interface {
	Send(ctx context.Context, n *models.Notification) error
	Broadcast(ctx context.Context, n *models.Notification, userIDs []uuid.UUID) error
	GetMyNotifications(ctx context.Context, userID uuid.UUID, limit, offset int) ([]models.Notification, error)
	MarkAsRead(ctx context.Context, id uuid.UUID) error
	MarkAllAsRead(ctx context.Context, userID uuid.UUID) error
	GetUnreadCount(ctx context.Context, userID uuid.UUID) (int, error)
}

type notificationUseCaseImpl struct {
	repo repository.NotificationRepository
	// In real scenario, add FCM/SMTP service here
}

func NewNotificationUseCase(repo repository.NotificationRepository) NotificationUseCase {
	return &notificationUseCaseImpl{repo: repo}
}

func (u *notificationUseCaseImpl) Send(ctx context.Context, n *models.Notification) error {
	err := u.repo.Create(ctx, n)
	if err != nil {
		return err
	}
	// TODO: Trigger Push Notification & Email
	return nil
}

func (u *notificationUseCaseImpl) Broadcast(ctx context.Context, n *models.Notification, userIDs []uuid.UUID) error {
	for _, userID := range userIDs {
		n.UserID = userID
		n.ID = uuid.Nil // Force new ID
		_ = u.repo.Create(ctx, n)
		// TODO: Trigger Push Notification
	}
	return nil
}

func (u *notificationUseCaseImpl) GetMyNotifications(ctx context.Context, userID uuid.UUID, limit, offset int) ([]models.Notification, error) {
	return u.repo.ListByUser(ctx, userID, limit, offset)
}

func (u *notificationUseCaseImpl) MarkAsRead(ctx context.Context, id uuid.UUID) error {
	return u.repo.MarkAsRead(ctx, id)
}

func (u *notificationUseCaseImpl) MarkAllAsRead(ctx context.Context, userID uuid.UUID) error {
	return u.repo.MarkAllAsRead(ctx, userID)
}

func (u *notificationUseCaseImpl) GetUnreadCount(ctx context.Context, userID uuid.UUID) (int, error) {
	return u.repo.GetUnreadCount(ctx, userID)
}
