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
	ListActivities(ctx context.Context, filter repository.ActivityFilter) ([]*models.VisitActivity, error)
}

type visitUseCaseImpl struct {
	visitRepo    repository.VisitRepository
	custRepo     repository.CustomerRepository
	taskRepo     repository.TaskRepository
	activityRepo repository.SalesActivityRepository
	leadRepo     repository.LeadRepository
	dealRepo     repository.DealRepository
}

func NewVisitUseCase(vr repository.VisitRepository, cr repository.CustomerRepository, tr repository.TaskRepository, ar repository.SalesActivityRepository, lr repository.LeadRepository, dr repository.DealRepository) VisitUseCase {
	return &visitUseCaseImpl{visitRepo: vr, custRepo: cr, taskRepo: tr, activityRepo: ar, leadRepo: lr, dealRepo: dr}
}

func (u *visitUseCaseImpl) CreateSchedule(ctx context.Context, s *models.VisitSchedule) (*models.VisitSchedule, error) {
	// Assure target existing
	if s.CustomerID != nil {
		_, err := u.custRepo.GetByID(ctx, *s.CustomerID)
		if err != nil {
			return nil, dberrors.ErrInvalidInput
		}
	} else if s.LeadID != nil {
		_, err := u.leadRepo.GetByID(ctx, *s.LeadID)
		if err != nil {
			return nil, dberrors.ErrInvalidInput
		}
	} else {
		return nil, errors.New("customer_id or lead_id is required")
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
	var targetLat, targetLng *float64
	var targetName string
	var targetRadius float64 = 100.0 // Default

	if activity.CustomerID != nil {
		customer, err := u.custRepo.GetByID(ctx, *activity.CustomerID)
		if err != nil {
			return nil, errors.New("invalid customer target for activity")
		}
		targetLat = customer.Latitude
		targetLng = customer.Longitude
		targetName = customer.Name
		targetRadius = float64(customer.CheckinRadius)
		
		// If it's linked to a schedule, enforce integrity
		if activity.ScheduleID != nil {
			sched, err := u.visitRepo.GetScheduleByID(ctx, *activity.ScheduleID)
			if err != nil || (sched.CustomerID != nil && *sched.CustomerID != *activity.CustomerID) {
				return nil, errors.New("schedule does not match customer target")
			}
		}
	} else if activity.LeadID != nil {
		lead, err := u.leadRepo.GetByID(ctx, *activity.LeadID)
		if err != nil {
			return nil, errors.New("invalid lead target for activity")
		}
		targetLat = lead.Latitude
		targetLng = lead.Longitude
		targetName = lead.Name
		targetRadius = 200.0 // Default for leads
		
		// If it's linked to a schedule, enforce integrity
		if activity.ScheduleID != nil {
			sched, err := u.visitRepo.GetScheduleByID(ctx, *activity.ScheduleID)
			if err != nil || (sched.LeadID != nil && *sched.LeadID != *activity.LeadID) {
				return nil, errors.New("schedule does not match lead target")
			}
		}
	} else {
		return nil, errors.New("customer_id or lead_id is required for activity")
	}

	// PROXIMITY VALIDATION! 
	// We calculate distance if the target has set coordinates
	if targetLat != nil && targetLng != nil {
		distMeters := distanceBetween(activity.Latitude, activity.Longitude, *targetLat, *targetLng)
		activity.Distance = &distMeters
		
		if activity.Type == models.VisitTypeCheckIn && !activity.IsOffline {
			if distMeters > targetRadius {
				return nil, errors.New("lokasi check-in berada di luar radius yang diizinkan")
			}
		}
	}

	err := u.visitRepo.LogActivity(ctx, activity)
	if err != nil {
		return nil, err
	}

	// === UNIFICATION LOGIC: Sync with SalesActivity ===
	if activity.Type == models.VisitTypeCheckIn {
		// Start a new SalesActivity session
		salesAct := &models.SalesActivity{
			UserID:            activity.SalesID,
			LeadID:            activity.LeadID,
			CustomerID:        activity.CustomerID,
			DealID:            activity.DealID,
			TaskDestinationID: activity.TaskDestinationID,
			Type:              models.ActivityTypeVisit,
			Title:             "Visit to " + targetName,
			Latitude:          &activity.Latitude,
			Longitude:         &activity.Longitude,
			CheckInTime:       &activity.CreatedAt,
			SelfiePhotoPath:   &activity.SelfiePhotoPath,
			PlacePhotoPath:    &activity.PlacePhotoPath,
			Distance:          activity.Distance,
			IsOffline:         activity.IsOffline,
			ActivityAt:        activity.CreatedAt,
		}
		if activity.Notes != nil {
			salesAct.Notes = activity.Notes
		}
		
		_ = u.activityRepo.Create(ctx, salesAct)
	} else if activity.Type == models.VisitTypeCheckOut {
		// Find the active session to close
		// We look for an open activity for this user and customer (and task destination if present)
		filter := repository.SalesActivityFilter{
			SalesID:    &activity.SalesID,
			LeadID:     activity.LeadID,
			CustomerID: activity.CustomerID,
		}
		
		activities, err := u.activityRepo.List(ctx, filter)
		if err == nil && len(activities) > 0 {
			var activeSession *models.SalesActivity
			for _, a := range activities {
				// Match logic: Open visit (CheckIn exists, CheckOut is nil)
				// If task-based, must match taskDestinationID
				if a.Type == models.ActivityTypeVisit && a.CheckOutTime == nil {
					if activity.TaskDestinationID != nil {
						if a.TaskDestinationID != nil && *a.TaskDestinationID == *activity.TaskDestinationID {
							activeSession = a
							break
						}
					} else {
						activeSession = a
						break
					}
				}
			}
			
			if activeSession != nil {
				activeSession.CheckOutTime = &activity.CreatedAt
				if activity.Notes != nil {
					activeSession.Outcome = activity.Notes // Checkout notes usually represent the outcome
					activeSession.Notes = activity.Notes
				}
				_ = u.activityRepo.Update(ctx, activeSession)
			}
		}

		// Mark Schedule as completed if checkout happens
		if activity.ScheduleID != nil {
			sched, _ := u.visitRepo.GetScheduleByID(ctx, *activity.ScheduleID)
			if sched != nil {
				sched.Status = models.ScheduleStatusCompleted
				_ = u.visitRepo.UpdateSchedule(ctx, sched)
			}
		}

		if activity.TaskDestinationID != nil {
			destID := *activity.TaskDestinationID
			// Mark Destination as Completed
			task, err := u.taskRepo.GetByDestinationID(ctx, destID)
			if err == nil && task != nil {
				for i := range task.Destinations {
					if task.Destinations[i].ID == destID {
						task.Destinations[i].Status = models.TaskStatusCompleted
						break
					}
				}
				
				// Check if all destinations are completed
				allDone := true
				for _, d := range task.Destinations {
					if d.Status != models.TaskStatusCompleted {
						allDone = false
						break
					}
				}
				
				if allDone {
					task.Status = models.TaskStatusCompleted
				} else {
					task.Status = models.TaskStatusInProgress
				}
				
				_ = u.taskRepo.Update(ctx, task)
			}
		}

		// AUTOMATIC WON LOGIC: If outcome is "PO Submitted" and DealID exists
		if activity.DealID != nil && activity.Notes != nil && (*activity.Notes == "PO Submitted" || *activity.Notes == "PO Terkirim") {
			newStage := models.DealStage("closed_won")
			notes := "Otomatis diubah menjadi WON melalui laporan kunjungan: " + *activity.Notes
			_ = u.dealRepo.UpdateStage(ctx, *activity.DealID, newStage, &activity.SalesID, &notes)
		}
	}

	return activity, nil
}

func (u *visitUseCaseImpl) GetActivitiesBySchedule(ctx context.Context, scheduleID uuid.UUID) ([]*models.VisitActivity, error) {
	return u.visitRepo.GetActivitiesBySchedule(ctx, scheduleID)
}

func (u *visitUseCaseImpl) ListActivities(ctx context.Context, filter repository.ActivityFilter) ([]*models.VisitActivity, error) {
	// Transition to Unified View: Fetch from sales_activities
	saFilter := repository.SalesActivityFilter{
		SalesID:    filter.SalesID,
		CustomerID: filter.CustomerID,
		StartDate:  filter.StartDate,
		EndDate:    filter.EndDate,
	}
	
	salesActivities, err := u.activityRepo.List(ctx, saFilter)
	if err != nil {
		return nil, err
	}
	
	var results []*models.VisitActivity
	for _, sa := range salesActivities {
		if sa.Type != models.ActivityTypeVisit {
			continue
		}
		
		// Map Check-In to VisitActivity
		if sa.CheckInTime != nil {
			checkIn := &models.VisitActivity{
				ID:                sa.ID,
				TaskDestinationID: sa.TaskDestinationID,
				SalesID:           sa.UserID,
				LeadID:            sa.LeadID,
				CustomerID:        sa.CustomerID,
				Type:              models.VisitTypeCheckIn,
				CreatedAt:         *sa.CheckInTime,
			}
			if sa.Latitude != nil { checkIn.Latitude = *sa.Latitude }
			if sa.Longitude != nil { checkIn.Longitude = *sa.Longitude }
			if sa.SelfiePhotoPath != nil { checkIn.SelfiePhotoPath = *sa.SelfiePhotoPath }
			if sa.PlacePhotoPath != nil { checkIn.PlacePhotoPath = *sa.PlacePhotoPath }
			if sa.Distance != nil { checkIn.Distance = sa.Distance }
			checkIn.IsOffline = sa.IsOffline
			checkIn.Notes = sa.Notes
			
			results = append(results, checkIn)
		}
		
		// Map Check-Out to VisitActivity
		if sa.CheckOutTime != nil {
			checkOut := &models.VisitActivity{
				ID:                sa.ID, // Use same session ID but different type
				TaskDestinationID: sa.TaskDestinationID,
				SalesID:           sa.UserID,
				LeadID:            sa.LeadID,
				CustomerID:        sa.CustomerID,
				Type:              models.VisitTypeCheckOut,
				CreatedAt:         *sa.CheckOutTime,
			}
			if sa.Latitude != nil { checkOut.Latitude = *sa.Latitude }
			if sa.Longitude != nil { checkOut.Longitude = *sa.Longitude }
			checkOut.IsOffline = sa.IsOffline
			checkOut.Notes = sa.Outcome // Use outcome for checkout notes
			
			results = append(results, checkOut)
		}
	}
	
	return results, nil
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
