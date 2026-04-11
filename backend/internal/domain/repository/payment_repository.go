package repository

import (
	"context"
	"crm_wowin_backend/internal/domain/models"

	"github.com/google/uuid"
)

type PaymentRepository interface {
	Create(ctx context.Context, p *models.Payment) error
	GetByActivityID(ctx context.Context, activityID uuid.UUID) (*models.Payment, error)
}
