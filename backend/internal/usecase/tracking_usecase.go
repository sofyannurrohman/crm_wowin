package usecase

import (
	"context"
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"
	"time"

	"github.com/google/uuid"
)

type TrackingUseCase interface {
	SyncPoints(ctx context.Context, salesID uuid.UUID, points []models.LocationPoint) error
	GetLivePositions(ctx context.Context) ([]models.SalesLivePosition, error)
	GetSessionRoute(ctx context.Context, salesID uuid.UUID, date time.Time) (*models.TrackingSession, error)
}

type trackingUseCaseImpl struct {
	repo repository.TrackingRepository
}

func NewTrackingUseCase(repo repository.TrackingRepository) TrackingUseCase {
	return &trackingUseCaseImpl{repo: repo}
}

func (u *trackingUseCaseImpl) SyncPoints(ctx context.Context, salesID uuid.UUID, points []models.LocationPoint) error {
	if len(points) == 0 {
		return nil
	}

	// Group points by date to handle multi-day sync if offline for long time
	pointsByDate := make(map[string][]models.LocationPoint)
	for _, p := range points {
		dateStr := p.RecordedAt.Format("2006-01-02")
		p.SalesID = salesID
		pointsByDate[dateStr] = append(pointsByDate[dateStr], p)
	}

	for dateStr, datePoints := range pointsByDate {
		date, _ := time.Parse("2006-01-02", dateStr)
		
		// 1. Get or Create Session for the day
		session, err := u.repo.GetOrCreateSession(ctx, salesID, date)
		if err != nil {
			return err
		}

		// 2. Assign session ID to points
		for i := range datePoints {
			datePoints[i].SessionID = session.ID
		}

		// 3. Save points to DB
		err = u.repo.SaveBatchPoints(ctx, datePoints)
		if err != nil {
			return err
		}

		// 4. Update session status based on last point (simple logic)
		lastPoint := datePoints[len(datePoints)-1]
		if session.StartedAt == nil {
			session.StartedAt = &datePoints[0].RecordedAt
		}
		
		status := models.TrackingStatusOnTheWay
		if lastPoint.Speed < 1.0 { // < 3.6 km/h
			status = models.TrackingStatusIdle
		}
		session.Status = status
		
		err = u.repo.UpdateSession(ctx, session)
		if err != nil {
			return err
		}

		// 5. Update Live Position for the latest point
		livePos := &models.SalesLivePosition{
			SalesID:      salesID,
			Latitude:     lastPoint.Latitude,
			Longitude:    lastPoint.Longitude,
			Status:       status,
			Speed:        lastPoint.Speed,
			Heading:      lastPoint.Heading,
			BatteryLevel: lastPoint.BatteryLevel,
			UpdatedAt:    lastPoint.RecordedAt,
		}
		err = u.repo.UpdateLivePosition(ctx, livePos)
		if err != nil {
			return err
		}
	}

	return nil
}

func (u *trackingUseCaseImpl) GetLivePositions(ctx context.Context) ([]models.SalesLivePosition, error) {
	return u.repo.GetLivePositions(ctx)
}

func (u *trackingUseCaseImpl) GetSessionRoute(ctx context.Context, salesID uuid.UUID, date time.Time) (*models.TrackingSession, error) {
	session, err := u.repo.GetOrCreateSession(ctx, salesID, date)
	if err != nil {
		return nil, err
	}

	geoJSON, err := u.repo.GetRouteGeometry(ctx, session.ID)
	if err != nil {
		return nil, err
	}

	session.RouteGeoJSON = geoJSON
	return session, nil
}
