package usecase

import (
	"context"
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"
	"time"

	"github.com/google/uuid"
)

type TaskUseCase interface {
	Create(ctx context.Context, task *models.Task) (*models.Task, error)
	GetByID(ctx context.Context, id uuid.UUID) (*models.Task, error)
	List(ctx context.Context, filter repository.TaskFilter) ([]*models.Task, error)
	Update(ctx context.Context, task *models.Task) (*models.Task, error)
	Delete(ctx context.Context, id uuid.UUID) error
	Complete(ctx context.Context, id uuid.UUID) error
}

type taskUC struct {
	repo repository.TaskRepository
}

func NewTaskUseCase(repo repository.TaskRepository) TaskUseCase {
	return &taskUC{repo: repo}
}

func (u *taskUC) Create(ctx context.Context, t *models.Task) (*models.Task, error) {
	if t.Status == "" {
		t.Status = models.TaskStatusTodo
	}
	if t.Priority == "" {
		t.Priority = models.TaskPriorityMedium
	}
	if err := u.repo.Create(ctx, t); err != nil {
		return nil, err
	}
	return t, nil
}

func (u *taskUC) GetByID(ctx context.Context, id uuid.UUID) (*models.Task, error) {
	return u.repo.GetByID(ctx, id)
}

func (u *taskUC) List(ctx context.Context, filter repository.TaskFilter) ([]*models.Task, error) {
	return u.repo.List(ctx, filter)
}

func (u *taskUC) Update(ctx context.Context, t *models.Task) (*models.Task, error) {
	if t.Status == models.TaskStatusCompleted && t.CompletedAt == nil {
		now := time.Now()
		t.CompletedAt = &now
	}
	if err := u.repo.Update(ctx, t); err != nil {
		return nil, err
	}
	return t, nil
}

func (u *taskUC) Delete(ctx context.Context, id uuid.UUID) error {
	return u.repo.Delete(ctx, id)
}

func (u *taskUC) Complete(ctx context.Context, id uuid.UUID) error {
	t, err := u.repo.GetByID(ctx, id)
	if err != nil {
		return err
	}
	now := time.Now()
	t.Status = models.TaskStatusCompleted
	t.CompletedAt = &now
	return u.repo.Update(ctx, t)
}
