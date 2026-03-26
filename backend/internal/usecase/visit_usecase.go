package usecase

import (
	"context"
	"crm_wowin_backend/internal/domain/dberrors"
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"
	"errors"
	"math"

	"github.com/google/uuid"
)

// VisitUseCase governs Sales visit scheduling & execution footprint (Check-In/Out)
type VisitUseCase interface {
	CreateSchedule(ctx context.Context, s *models.VisitSchedule) (*models.VisitSchedule, error)
	GetSchedule(ctx context.Context, id uuid.UUID) (*models.VisitSchedule, error)
	ListSchedules(ctx context.Context, filter repository.ScheduleFilter) ([]*models.VisitSchedule, error)
	UpdateSchedule(ctx context.Context, s *models.VisitSchedule) (*models.VisitSchedule, error)

	// Check-in and Check-out
	LogActivity(ctx context.Context, activity *models.VisitActivity) (*models.VisitActivity, error)
	GetActivitiesBySchedule(ctx context.Context, scheduleID uuid.UUID) ([]*models.VisitActivity, error)
}

type visitUseCaseImpl struct {
	visitRepo repository.VisitRepository
	custRepo  repository.CustomerRepository
}

func NewVisitUseCase(vr repository.VisitRepository, cr repository.CustomerRepository) VisitUseCase {
	return &visitUseCaseImpl{visitRepo: vr, custRepo: cr}
}

func (u *visitUseCaseImpl) CreateSchedule(ctx context.Context, s *models.VisitSchedule) (*models.VisitSchedule, error) {
	// Assure target customer existing
	_, err := u.custRepo.GetByID(ctx, s.CustomerID)
	if err != nil {
		return nil, dberrors.ErrInvalidInput
	}
	
	if s.Status == "" {
		s.Status = models.ScheduleStatusScheduled
	}
	
	if err := u.visitRepo.CreateSchedule(ctx, s); err != nil {
		return nil, err
	}
	return s, nil
}

func (u *visitUseCaseImpl) GetSchedule(ctx context.Context, id uuid.UUID) (*models.VisitSchedule, error) {
	return u.visitRepo.GetScheduleByID(ctx, id)
}

func (u *visitUseCaseImpl) ListSchedules(ctx context.Context, filter repository.ScheduleFilter) ([]*models.VisitSchedule, error) {
	return u.visitRepo.ListSchedules(ctx, filter)
}

func (u *visitUseCaseImpl) UpdateSchedule(ctx context.Context, s *models.VisitSchedule) (*models.VisitSchedule, error) {
	existing, err := u.visitRepo.GetScheduleByID(ctx, s.ID)
	if err != nil {
		return nil, err
	}

	// Ensure fixed pointers stick
	s.SalesID = existing.SalesID
	if err := u.visitRepo.UpdateSchedule(ctx, s); err != nil {
		return nil, err
	}
	return s, nil
}

// LogActivity validates proximity for checkins and registers photo path proofs.
func (u *visitUseCaseImpl) LogActivity(ctx context.Context, activity *models.VisitActivity) (*models.VisitActivity, error) {
	customer, err := u.custRepo.GetByID(ctx, activity.CustomerID)
	if err != nil {
		return nil, errors.New("invalid customer target for activity")
	}

	// If it's linked to a schedule, enforce integrity
	if activity.ScheduleID != nil {
		sched, err := u.visitRepo.GetScheduleByID(ctx, *activity.ScheduleID)
		if err != nil || sched.CustomerID != activity.CustomerID {
			return nil, errors.New("schedule does not match customer target")
		}
	}

	// PROXIMITY VALIDATION! 
	// We calculate distance if the target customer has set coordinates
	if customer.Latitude != nil && customer.Longitude != nil {
		distMeters := distanceBetween(activity.Latitude, activity.Longitude, *customer.Latitude, *customer.Longitude)
		activity.Distance = &distMeters
		
		// Optional: We can reject checkin here if `distMeters` > `customer.CheckinRadius`, 
		// but usually in enterprise CRMs, we allow storing the "far" checkin, yet marking it as "violation notes" 
		// or rejecting strictly based on client SOP.
		// For Phase 1 strictness:
		if activity.Type == models.VisitTypeCheckIn && !activity.IsOffline {
			if distMeters > float64(customer.CheckinRadius) {
				return nil, errors.New("lokasi check-in berada di luar radius pelanggan yang diizinkan")
			}
		}
	}

	err = u.visitRepo.LogActivity(ctx, activity)
	if err != nil {
		return nil, err
	}

	// Mark Schedule as completed if checkout happens
	if activity.Type == models.VisitTypeCheckOut && activity.ScheduleID != nil {
		sched, _ := u.visitRepo.GetScheduleByID(ctx, *activity.ScheduleID)
		if sched != nil {
			sched.Status = models.ScheduleStatusCompleted
			_ = u.visitRepo.UpdateSchedule(ctx, sched)
		}
	}

	return activity, nil
}

func (u *visitUseCaseImpl) GetActivitiesBySchedule(ctx context.Context, scheduleID uuid.UUID) ([]*models.VisitActivity, error) {
	return u.visitRepo.GetActivitiesBySchedule(ctx, scheduleID)
}

// ==============
// UTILS
// ==============

// Haversine distance formula estimation - mostly accurate enough for < 100km radius gating without hitting DB 
// (For high precision, PostGIS `ST_Distance(geo1, geo2)` should be invoked)
func distanceBetween(lat1, lon1, lat2, lon2 float64) float64 {
	const earthRadiusMeters = 6371000.0

	rad := math.Pi / 180.0
	dLat := (lat2 - lat1) * rad
	dLon := (lon2 - lon1) * rad

	a := math.Sin(dLat/2)*math.Sin(dLat/2) +
		math.Cos(lat1*rad)*math.Cos(lat2*rad)*
			math.Sin(dLon/2)*math.Sin(dLon/2)
	c := 2 * math.Atan2(math.Sqrt(a), math.Sqrt(1-a))

	return earthRadiusMeters * c
}
