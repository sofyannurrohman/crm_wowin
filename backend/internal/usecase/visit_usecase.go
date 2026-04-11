package usecase

import (
	"context"
	"crm_wowin_backend/internal/domain/dberrors"
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"
	"errors"
	"math"
	"strings"

	"github.com/google/uuid"
)

// VisitUseCase governs Sales visit scheduling & execution footprint (Check-In/Out)
type VisitUseCase interface {
	CreateSchedule(ctx context.Context, s *models.VisitSchedule) (*models.VisitSchedule, error)
	GetSchedule(ctx context.Context, id uuid.UUID) (*models.VisitSchedule, error)
	ListSchedules(ctx context.Context, filter repository.ScheduleFilter) ([]*models.VisitSchedule, error)
	UpdateSchedule(ctx context.Context, s *models.VisitSchedule) (*models.VisitSchedule, error)

	// Check-in and Check-out
	GetActiveActivity(ctx context.Context, salesID uuid.UUID) (*models.VisitActivity, error)
	LogActivity(ctx context.Context, activity *models.VisitActivity) (*models.VisitActivity, error)
	GetActivitiesBySchedule(ctx context.Context, scheduleID uuid.UUID) ([]*models.VisitActivity, error)
	ListActivities(ctx context.Context, filter repository.ActivityFilter) ([]*models.VisitActivity, error)
	GetTaskByDestinationID(ctx context.Context, destID uuid.UUID) (*models.Task, error)
}

type visitUseCaseImpl struct {
	visitRepo    repository.VisitRepository
	custRepo     repository.CustomerRepository
	taskRepo     repository.TaskRepository
	activityRepo repository.SalesActivityRepository
	leadRepo     repository.LeadRepository
	dealRepo     repository.DealRepository
	userRepo     repository.UserRepository
	vanStockRepo repository.VanStockRepository
	paymentRepo  repository.PaymentRepository
}

func NewVisitUseCase(
	vr repository.VisitRepository,
	cr repository.CustomerRepository,
	tr repository.TaskRepository,
	ar repository.SalesActivityRepository,
	lr repository.LeadRepository,
	dr repository.DealRepository,
	ur repository.UserRepository,
	vsr repository.VanStockRepository,
	pr repository.PaymentRepository,
) VisitUseCase {
	return &visitUseCaseImpl{
		visitRepo:    vr,
		custRepo:     cr,
		taskRepo:     tr,
		activityRepo: ar,
		leadRepo:     lr,
		dealRepo:     dr,
		userRepo:     ur,
		vanStockRepo: vsr,
		paymentRepo:  pr,
	}
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

	// Fetch Sales Person details to check SalesType
	user, err := u.userRepo.FindByID(ctx, activity.SalesID)
	if err != nil {
		return nil, errors.New("failed to fetch salesman info")
	}

	// PROXIMITY VALIDATION! 
	// We calculate distance if the target has set coordinates
	if targetLat != nil && targetLng != nil {
		distMeters := distanceBetween(activity.Latitude, activity.Longitude, *targetLat, *targetLng)
		activity.Distance = &distMeters
		
		if activity.Type == models.VisitTypeCheckIn && !activity.IsOffline {
			// Apply 300m tolerance for Motoris
			effectiveRadius := targetRadius
			if user.SalesType != nil && *user.SalesType == models.SalesTypeMotoris {
				effectiveRadius = 300.0
			}

			if distMeters > effectiveRadius {
				return nil, errors.New("lokasi check-in berada di luar radius yang diizinkan")
			}
		}
	}

	err = u.visitRepo.LogActivity(ctx, activity)
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
			SignaturePath:     &activity.SignaturePath,
			Distance:          activity.Distance,
			IsOffline:         activity.IsOffline,
			ActivityAt:        activity.CreatedAt,
		}
		if activity.Notes != nil {
			salesAct.Notes = activity.Notes
		}
		
		_ = u.activityRepo.Create(ctx, salesAct)

		// Mark Destination as In Progress if it's task-based
		if activity.TaskDestinationID != nil {
			destID := *activity.TaskDestinationID
			task, err := u.taskRepo.GetByDestinationID(ctx, destID)
			if err == nil && task != nil {
				for i := range task.Destinations {
					if task.Destinations[i].ID == destID {
						task.Destinations[i].Status = models.TaskStatusInProgress
						break
					}
				}
				_ = u.taskRepo.Update(ctx, task)
			}
		}
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
				activeSession.SignaturePath = &activity.SignaturePath
				if activity.Outcome != nil {
					activeSession.Outcome = activity.Outcome
				}
				if activity.Notes != nil {
					activeSession.Notes = activity.Notes
				}
				_ = u.activityRepo.Update(ctx, activeSession)
			}
		}

		// Handle DealItems if provided during Checkout
		if len(activity.DealItems) > 0 && activity.DealID == nil {
			var dAmount float64
			for _, it := range activity.DealItems {
				dAmount += it.UnitPrice * it.Quantity
			}

			salesmanID := activity.SalesID
			newDeal := &models.Deal{
				Title:       "Deal dari Kunjungan: " + targetName,
				CustomerID:  activity.CustomerID,
				LeadID:      activity.LeadID,
				AssignedTo:  &salesmanID,
				Stage:       models.DealStageProspect,
				Status:      models.DealStatusOpen,
				Amount:      &dAmount,
				Probability: 10,
				Items:       activity.DealItems,
				CreatedBy:   &salesmanID,
			}
			
			if activity.Notes != nil {
				newDeal.Description = activity.Notes
			}
			
			// Structured Outcome Logic for new deals
			isWon := false
			if activity.Outcome != nil && *activity.Outcome == "deal_won" {
				isWon = true
			} else if activity.Notes != nil {
				// Fallback for legacy keyword matching
				noteLower := strings.ToLower(*activity.Notes)
				if strings.Contains(noteLower, "closing") || strings.Contains(noteLower, "bungkus") {
					isWon = true
				}
			}

			if isWon {
				// Canvas Logic: Check Inventory
				if user.SalesType != nil && *user.SalesType == models.SalesTypeCanvas {
					canFulfill := true
					for _, it := range activity.DealItems {
						vs, err := u.vanStockRepo.GetByUserAndProduct(ctx, user.ID, it.ProductID)
						if err != nil || vs == nil || vs.Quantity < it.Quantity {
							canFulfill = false
							break
						}
					}

					if !canFulfill {
						// Downgrade to Pre-Order instead of Won
						newDeal.Stage = models.DealStagePreOrder
						newDeal.Status = models.DealStatusOpen
						newDeal.Probability = 50
					} else {
						// Fulfill and Deduct
						newDeal.Stage = models.DealStageClosedWon
						newDeal.Status = models.DealStatusWon
						newDeal.Probability = 100
						for _, it := range activity.DealItems {
							_ = u.vanStockRepo.DeductStock(ctx, user.ID, it.ProductID, it.Quantity)
						}
						
						// Create Payment record if it's a direct sale
						payment := &models.Payment{
							ActivityID: activity.ID,
							Amount:     dAmount,
							Method:     models.PaymentMethodCash, // Default, mobile can override
						}
						_ = u.paymentRepo.Create(ctx, payment)
					}
				} else {
					// Traditional won
					newDeal.Stage = models.DealStageClosedWon
					newDeal.Status = models.DealStatusWon
					newDeal.Probability = 100
				}
			}

			if err := u.dealRepo.Create(ctx, newDeal); err == nil {
				activity.DealID = &newDeal.ID
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
					activity.TaskCompleted = true
				} else {
					task.Status = models.TaskStatusInProgress
				}
				
				_ = u.taskRepo.Update(ctx, task)
			}
		}

		// AUTOMATIC WON LOGIC for existing deals
		if activity.DealID != nil {
			isWon := false
			if activity.Outcome != nil && *activity.Outcome == "deal_won" {
				isWon = true
			} else if activity.Notes != nil {
				noteLower := strings.ToLower(*activity.Notes)
				if strings.Contains(noteLower, "closing") || strings.Contains(noteLower, "bungkus") || strings.Contains(noteLower, "po submitted") || strings.Contains(noteLower, "po terkirim") {
					isWon = true
				}
			}

			if isWon {
				newStage := models.DealStageClosedWon
				outcomeStr := "Structured outcome"
				if activity.Outcome != nil { outcomeStr = *activity.Outcome }
				notes := "Otomatis diubah menjadi WON melalui laporan kunjungan: " + outcomeStr
				_ = u.dealRepo.UpdateStage(ctx, *activity.DealID, newStage, &activity.SalesID, &notes)
			}
		}
	}

	return activity, nil
}

func (u *visitUseCaseImpl) GetActiveActivity(ctx context.Context, salesID uuid.UUID) (*models.VisitActivity, error) {
	filter := repository.SalesActivityFilter{
		SalesID: &salesID,
	}
	activities, err := u.activityRepo.List(ctx, filter)
	if err != nil {
		return nil, err
	}

	for _, sa := range activities {
		if sa.Type == models.ActivityTypeVisit && sa.CheckOutTime == nil {
			// Found active session
			return &models.VisitActivity{
				ID:                sa.ID,
				SalesID:           sa.UserID,
				CustomerID:        sa.CustomerID,
				LeadID:            sa.LeadID,
				DealID:            sa.DealID,
				TaskDestinationID: sa.TaskDestinationID,
				Type:              models.VisitTypeCheckIn,
				Latitude:          *sa.Latitude,
				Longitude:         *sa.Longitude,
				CreatedAt:         *sa.CheckInTime,
				IsOffline:         sa.IsOffline,
				Notes:             sa.Notes,
			}, nil
		}
	}

	return nil, dberrors.ErrNotFound
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
				DealID:            sa.DealID,
				DealTitle:         sa.DealTitle,
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
				DealID:            sa.DealID,
				DealTitle:         sa.DealTitle,
				Type:              models.VisitTypeCheckOut,
				CreatedAt:         *sa.CheckOutTime,
			}
			if sa.Latitude != nil { checkOut.Latitude = *sa.Latitude }
			if sa.Longitude != nil { checkOut.Longitude = *sa.Longitude }
			checkOut.IsOffline = sa.IsOffline
			checkOut.Notes = sa.Outcome // Use outcome for checkout notes
			checkOut.Outcome = sa.Outcome
			
			results = append(results, checkOut)
		}
	}
	
	return results, nil
}

func (u *visitUseCaseImpl) GetTaskByDestinationID(ctx context.Context, destID uuid.UUID) (*models.Task, error) {
	return u.taskRepo.GetByDestinationID(ctx, destID)
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
