package repository

import (
	"context"
	"crm_wowin_backend/internal/domain/models"

	"github.com/google/uuid"
)

type TerritoryRepository interface {
	Create(ctx context.Context, territory *models.Territory) error
	GetByID(ctx context.Context, id uuid.UUID) (*models.Territory, error)
	List(ctx context.Context) ([]*models.Territory, error)
	Update(ctx context.Context, territory *models.Territory) error
	Delete(ctx context.Context, id uuid.UUID) error
	
	AssignUser(ctx context.Context, territoryID, userID, assignedBy uuid.UUID) error
	UnassignUser(ctx context.Context, territoryID, userID uuid.UUID) error
	ListUsers(ctx context.Context, territoryID uuid.UUID) ([]uuid.UUID, error)
}
