package models

import (
	"time"

	"github.com/google/uuid"
)

type NotificationType string

const (
	NotificationTypeVisitReminder NotificationType = "visit_reminder"
	NotificationTypeFollowUp      NotificationType = "follow_up"
	NotificationTypeDealUpdate     NotificationType = "deal_update"
	NotificationTypeApproval      NotificationType = "approval"
	NotificationTypeBroadcast     NotificationType = "broadcast"
	NotificationTypeSystem        NotificationType = "system"
)

type Notification struct {
	ID         uuid.UUID        `json:"id"`
	UserID     uuid.UUID        `json:"user_id"`
	Type       NotificationType `json:"type"`
	Title      string           `json:"title"`
	Body       string           `json:"body"`
	EntityType string           `json:"entity_type"`
	EntityID   *uuid.UUID       `json:"entity_id"`
	IsRead     bool             `json:"is_read"`
	ReadAt     *time.Time       `json:"read_at"`
	SentAt     *time.Time       `json:"sent_at"`
	CreatedAt  time.Time        `json:"created_at"`
}
