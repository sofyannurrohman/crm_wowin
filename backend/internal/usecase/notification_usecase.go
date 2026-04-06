package usecase

import (
	"context"
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"
	"crm_wowin_backend/pkg/email"
	"crm_wowin_backend/pkg/websocket"
	"fmt"
	"log"

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
	if websocket.DefaultHub != nil {
		websocket.DefaultHub.PushNotification(n.UserID.String(), n)
	}
	
	// Fire email asynchronously
	go func() {
		// Mock email address for now, realistically we should fetch the user from a Repo to get their actual email
		mockUserEmail := fmt.Sprintf("user_%s@example.com", n.UserID.String())
		errEmail := email.SendNotificationEmail(
			mockUserEmail,
			"CRM Wowin: " + n.Title,
			n.Body,
		)
		if errEmail != nil {
			log.Printf("Failed to send notification email: %v", errEmail)
		}
	}()
	return nil
}

func (u *notificationUseCaseImpl) Broadcast(ctx context.Context, n *models.Notification, userIDs []uuid.UUID) error {
	for _, userID := range userIDs {
		n.UserID = userID
		n.ID = uuid.Nil // Force new ID
		_ = u.repo.Create(ctx, n)
		if websocket.DefaultHub != nil {
			websocket.DefaultHub.PushNotification(userID.String(), n)
		}
		
		go func(uID uuid.UUID, notif *models.Notification) {
			mockUserEmail := fmt.Sprintf("user_%s@example.com", uID.String())
			email.SendNotificationEmail(
				mockUserEmail,
				"CRM Wowin: " + notif.Title,
				notif.Body,
			)
		}(userID, n)
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
