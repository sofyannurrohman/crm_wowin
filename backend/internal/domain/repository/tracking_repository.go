package repository

import (
	"context"
	"crm_wowin_backend/internal/domain/models"
	"time"

	"github.com/google/uuid"
)

type TrackingRepository interface {
	// Sessions
	GetOrCreateSession(ctx context.Context, salesID uuid.UUID, date time.Time) (*models.TrackingSession, error)
	GetSessionByID(ctx context.Context, id uuid.UUID) (*models.TrackingSession, error)
	UpdateSession(ctx context.Context, session *models.TrackingSession) error

	// Points
	SaveBatchPoints(ctx context.Context, points []models.LocationPoint) error
	
	// Live tracking
	UpdateLivePosition(ctx context.Context, pos *models.SalesLivePosition) error
	GetLivePositions(ctx context.Context) ([]models.SalesLivePosition, error)
	
	// Analysis
	GetRouteGeometry(ctx context.Context, sessionID uuid.UUID) (interface{}, error)
}
