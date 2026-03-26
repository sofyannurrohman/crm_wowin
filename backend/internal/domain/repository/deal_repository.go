package repository

import (
	"context"
	"crm_wowin_backend/internal/domain/models"

	"github.com/google/uuid"
)

type LeadFilter struct {
	Status     string
	AssignedTo *uuid.UUID
	Search     string
}

// LeadRepository handles interactions affecting prospective leads
type LeadRepository interface {
	Create(ctx context.Context, lead *models.Lead) error
	GetByID(ctx context.Context, id uuid.UUID) (*models.Lead, error)
	List(ctx context.Context, filter LeadFilter) ([]*models.Lead, error)
	Update(ctx context.Context, lead *models.Lead) error
	Delete(ctx context.Context, id uuid.UUID) error
}

type DealFilter struct {
	CustomerID *uuid.UUID
	AssignedTo *uuid.UUID
	Stage      string
	Status     string
}

// DealRepository manages the pipelines, deal amounts and stages
type DealRepository interface {
	Create(ctx context.Context, deal *models.Deal) error
	GetByID(ctx context.Context, id uuid.UUID) (*models.Deal, error)
	List(ctx context.Context, filter DealFilter) ([]*models.Deal, error)
	Update(ctx context.Context, deal *models.Deal) error
	
	// Kanban style movement generates history trail
	UpdateStage(ctx context.Context, dealID uuid.UUID, newStage models.DealStage, changedBy *uuid.UUID, notes *string) error
	GetStageHistory(ctx context.Context, dealID uuid.UUID) ([]*models.DealStageHistory, error)
}
