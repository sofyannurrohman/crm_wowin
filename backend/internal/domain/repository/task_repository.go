package repository

import (
	"context"
	"crm_wowin_backend/internal/domain/models"

	"github.com/google/uuid"
)

type TaskFilter struct {
	SalesID    *uuid.UUID
	CustomerID *uuid.UUID
	Status     models.TaskStatus
}

type TaskRepository interface {
	Create(ctx context.Context, task *models.Task) error
	GetByID(ctx context.Context, id uuid.UUID) (*models.Task, error)
	List(ctx context.Context, filter TaskFilter) ([]*models.Task, error)
	Update(ctx context.Context, task *models.Task) error
	Delete(ctx context.Context, id uuid.UUID) error
}
