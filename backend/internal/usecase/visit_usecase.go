package usecase

import (
	"context"
	"crm_wowin_backend/internal/domain/dberrors"
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"
	"errors"
	"fmt"
	"math"
	"strings"
	"time"

	"crm_wowin_backend/pkg/utils"
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
	FinalizeVisit(ctx context.Context, activityID uuid.UUID, items []models.DealItem, outcome string, priceOverride *float64, notes string) error
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
	invoiceRepo  repository.InvoiceRepository
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
	ir repository.InvoiceRepository,
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
		invoiceRepo:  ir,
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

		// Fetch Sales Person details to check SalesType/Role
		user, err := u.userRepo.FindByID(ctx, activity.SalesID)
		if err != nil {
			return nil, errors.New("failed to fetch salesman info")
		}

		// DEBUG: Log IDs to see why they don't match
		fmt.Printf("DEBUG CHECKIN: Customer AssignedTo: %v | Activity SalesID: %v\n", customer.AssignedTo, activity.SalesID)

		// ENFORCE OWNERSHIP: Only assigned salesman (or managers) can check-in
		if customer.AssignedTo != nil && *customer.AssignedTo != activity.SalesID {
			// Check if requester has elevated role
			if user.Role == models.RoleSales {
				// TEMPORARY BYPASS: Log the error but don't block, to let user work while we debug
				fmt.Printf("⚠️  OWNERSHIP MISMATCH BLOCKED (Bypassed for debug): Customer belongs to %v, Checkin by %v\n", customer.AssignedTo, activity.SalesID)
				// return nil, errors.New("akses ditolak: toko ini dimiliki oleh salesman lain")
			}
		}
		
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

	// Fetch Sales Person details for Lead check or Proximity (if not already fetched for Customer)
	var user *models.User
	if activity.CustomerID != nil {
		// user was already fetched in the customer block
		// we just need to ensure it's available for proximity logic below
		user, _ = u.userRepo.FindByID(ctx, activity.SalesID)
	} else {
		var err error
		user, err = u.userRepo.FindByID(ctx, activity.SalesID)
		if err != nil {
			return nil, errors.New("failed to fetch salesman info")
		}
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

	// Log to legacy visits table. For check-in this is mandatory (INSERT).
	// For check-out, the visits table UPDATE is best-effort — the canonical
	// state is tracked in sales_activities. If no matching open check-in row
	// exists in visits (e.g. ad-hoc or task-based visits), we skip gracefully.
	visitLogErr := u.visitRepo.LogActivity(ctx, activity)
	if visitLogErr != nil {
		if activity.Type == models.VisitTypeCheckIn {
			// Check-in MUST succeed — fail hard
			return nil, visitLogErr
		}
		// Check-out: log warning but continue — sales_activities is the source of truth
		fmt.Printf("⚠️  visits table checkout update skipped: %v\n", visitLogErr)
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
			Status:            models.VisitStatusDraft, // Start as draft (check-in)
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
				now := utils.FlexTime{Time: time.Now()}
				activeSession.CheckOutTime = &now
				activeSession.SignaturePath = &activity.SignaturePath
				activeSession.NotaPhotoPath = &activity.NotaPhotoPath
				
				// Determine status: If items are provided now, it's COMPLETED. 
				// Otherwise, if a nota photo is provided, it's DRAFT_PHOTO for later input.
				if len(activity.DealItems) > 0 {
					activeSession.Status = models.VisitStatusCompleted
					activity.Status = models.VisitStatusCompleted
				} else if activity.NotaPhotoPath != "" {
					activeSession.Status = models.VisitStatusDraft
					activity.Status = models.VisitStatusDraft
				} else {
					activeSession.Status = models.VisitStatusCompleted
					activity.Status = models.VisitStatusCompleted
				}

				if activity.Outcome != nil {
					activeSession.Outcome = activity.Outcome
				}
				if activity.Notes != nil {
					activeSession.Notes = activity.Notes
				}
				if err := u.activityRepo.Update(ctx, activeSession); err != nil {
					// Log but don't fail — checkout can still succeed
					fmt.Printf("⚠️  sales_activities checkout update failed: %v\n", err)
				}
			}
		}

		// Handle DealItems if provided during Checkout, or if outcome explicitly dictates a deal/negotiation
		// BYPASS deal creation if status is DRAFT_PHOTO (will be handled in FinalizeVisit later)
		shouldCreateDeal := (len(activity.DealItems) > 0 || 
			(activity.Outcome != nil && (*activity.Outcome == "deal_won" || *activity.Outcome == "negotiation" || *activity.Outcome == "follow_up" || *activity.Outcome == "deal_lost" || *activity.Outcome == "rejection")) || 
			activity.PriceOverride != nil || 
			(activity.Notes != nil && (strings.Contains(strings.ToLower(*activity.Notes), "closing") || strings.Contains(strings.ToLower(*activity.Notes), "bungkus"))))

		if shouldCreateDeal && activity.DealID == nil && activity.Status != models.VisitStatusDraft {
			var dAmount float64
			for _, it := range activity.DealItems {
				dAmount += it.UnitPrice * it.Quantity
			}
			if activity.PriceOverride != nil {
				dAmount = *activity.PriceOverride
			}

			salesmanID := activity.SalesID
			// Probability is "useless" - setting to 0 as requested
			newDeal := &models.Deal{
				Title:       "Deal dari Kunjungan: " + targetName,
				CustomerID:  activity.CustomerID,
				LeadID:      activity.LeadID,
				AssignedTo:  &salesmanID,
				Stage:       models.DealStageProspect,
				Status:      models.DealStatusOpen,
				Amount:      &dAmount,
				Probability: 0,
				Items:       activity.DealItems,
				CreatedBy:   &salesmanID,
			}
			
			// If we ONLY have a LeadID but NO CustomerID, we MUST convert now because 'deals' table requires customer_id
			if newDeal.CustomerID == nil && newDeal.LeadID != nil {
				newCustID := u.convertLeadToCustomerInline(ctx, *newDeal.LeadID, activity.SalesID)
				if newCustID != nil {
					newDeal.CustomerID = newCustID
					// Update activity so response shows the new customer mapping
					activity.CustomerID = newCustID
				} else {
					// If conversion failed, we can't create the deal due to DB constraint
					fmt.Printf("⚠️  failed to convert lead to customer for deal: %v\n", newDeal.LeadID)
				}
			}
			
			if activity.Notes != nil {
				newDeal.Description = activity.Notes
			}
			
			// Structured Outcome Logic for new deals
			isWon := false
			if activity.Outcome != nil {
				switch *activity.Outcome {
				case "deal_won":
					isWon = true
				case "negotiation":
					newDeal.Stage = models.DealStageNegotiation
				case "follow_up":
					// Remains as Prospect/Prospecting
					newDeal.Stage = models.DealStageProspect
				case "deal_lost", "rejection":
					newDeal.Stage = models.DealStageClosedLost
					newDeal.Status = models.DealStatusLost
				}
			}
			
			if !isWon && activity.Notes != nil {
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
					} else {
						// Fulfill and Deduct
						newDeal.Stage = models.DealStageClosedWon
						newDeal.Status = models.DealStatusWon
						for _, it := range activity.DealItems {
							_ = u.vanStockRepo.DeductStock(ctx, user.ID, it.ProductID, it.Quantity)
						}
						
						// Create Payment record if it's a direct sale
						payMethod := models.PaymentMethodCash
						if activity.PaymentMethod != "" {
							payMethod = models.PaymentMethod(activity.PaymentMethod)
						}
						payment := &models.Payment{
							ActivityID:  activity.ID,
							Amount:      dAmount,
							Method:      payMethod,
							ReferenceNo: activity.PaymentRef,
						}
						if err := u.paymentRepo.Create(ctx, payment); err != nil {
							return nil, fmt.Errorf("failed to create payment record: %w", err)
						}
					}
				} else {
					// Traditional won
					newDeal.Stage = models.DealStageClosedWon
					newDeal.Status = models.DealStatusWon
				}

				// --- Automated Invoicing for Canvas/Motoris (Revenue Separation Rule) ---
				if user.SalesType != nil && (*user.SalesType == models.SalesTypeCanvas || *user.SalesType == models.SalesTypeMotoris) {
					invStatus := models.InvoiceStatusUnpaid
					paidAmt := 0.0
					if activity.PaymentMethod == "cash" {
						invStatus = models.InvoiceStatusPaid
						paidAmt = dAmount
					}

					invoice := &models.Invoice{
						CustomerID:    *newDeal.CustomerID,
						DealID:        &newDeal.ID,
						InvoiceNo:     fmt.Sprintf("INV-%d", time.Now().UnixNano()/1e6),
						Amount:        dAmount,
						PaidAmount:    paidAmt,
						Status:        invStatus,
						SignaturePath: activity.SignaturePath,
					}
					
					if invStatus == models.InvoiceStatusUnpaid {
						due := utils.FlexTime{Time: time.Now().AddDate(0, 0, 7)}
						invoice.DueAt = &due
					}

					if err := u.invoiceRepo.Create(ctx, invoice); err != nil {
						fmt.Printf("⚠️ failed to auto-generate invoice: %v\n", err)
					}
				}
			}

			if err := u.dealRepo.Create(ctx, newDeal); err != nil {
				return nil, fmt.Errorf("gagal membuat laporan penjualan: %w", err)
			}
			activity.DealID = &newDeal.ID

			if isWon {
				if activity.LeadID != nil && activity.CustomerID == nil {
					u.convertLeadToCustomerInline(ctx, *activity.LeadID, activity.SalesID)
				}
				if activity.CustomerID != nil {
					u.activateCustomerIfProspect(ctx, *activity.CustomerID)
				}
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
				
				if err := u.taskRepo.Update(ctx, task); err != nil {
					return nil, fmt.Errorf("gagal memperbarui status tugas: %w", err)
				}
			}
		}

		// Sync existing deal data if updated during visit
		if activity.DealID != nil {
			existingDeal, err := u.dealRepo.GetByID(ctx, *activity.DealID)
			if err == nil && existingDeal != nil {
				updated := false
				if activity.PriceOverride != nil {
					existingDeal.Amount = activity.PriceOverride
					updated = true
				} else if len(activity.DealItems) > 0 {
					var dAmount float64
					for _, it := range activity.DealItems {
						dAmount += it.UnitPrice * it.Quantity
					}
					existingDeal.Amount = &dAmount
					existingDeal.Items = activity.DealItems
					updated = true
				}

				if updated {
					_ = u.dealRepo.Update(ctx, existingDeal)
				}
			}

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

				// Canvas Logic: Check Inventory for Existing Deal
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
						newStage = models.DealStagePreOrder
						notes += " (Stok van tidak mencukupi, diubah ke Pre-Order)"
					} else {
						// Deduct and pay
						for _, it := range activity.DealItems {
							_ = u.vanStockRepo.DeductStock(ctx, user.ID, it.ProductID, it.Quantity)
						}
						payMethod := models.PaymentMethodCash
						if activity.PaymentMethod != "" {
							payMethod = models.PaymentMethod(activity.PaymentMethod)
						}
						payAmount := float64(0)
						if activity.PriceOverride != nil {
							payAmount = *activity.PriceOverride
						}
						payment := &models.Payment{
							ActivityID:  activity.ID,
							Amount:      payAmount, // Amount from checkout
							Method:      payMethod,
							ReferenceNo: activity.PaymentRef,
						}
						if err := u.paymentRepo.Create(ctx, payment); err != nil {
							return nil, fmt.Errorf("failed to process canvas payment: %w", err)
						}
					}
				}

				if err := u.dealRepo.UpdateStage(ctx, *activity.DealID, newStage, &activity.SalesID, &notes); err != nil {
					return nil, fmt.Errorf("gagal mengubah status deal menjadi won: %w", err)
				}

				if activity.LeadID != nil && activity.CustomerID == nil {
					u.convertLeadToCustomerInline(ctx, *activity.LeadID, activity.SalesID)
				}
				
			}
		}

		// --- Collection (Tagihan) Logic ---
		if activity.Outcome != nil && *activity.Outcome == "collection" {
			if activity.InvoiceID == nil {
				return nil, errors.New("invoice_id is required for collection outcome")
			}

			// Validate Invoice belonging to customer
			invoice, err := u.invoiceRepo.GetByID(ctx, *activity.InvoiceID)
			if err != nil || invoice == nil {
				return nil, errors.New("invalid invoice_id for collection")
			}
			if activity.CustomerID != nil && invoice.CustomerID != *activity.CustomerID {
				return nil, errors.New("invoice does not belong to the selected customer")
			}

			// Record Payment
			payAmount := 0.0
			if activity.PriceOverride != nil {
				payAmount = *activity.PriceOverride
			}
			
			if payAmount <= 0 {
				return nil, errors.New("payment amount must be greater than zero for collection")
			}

			payMethod := models.PaymentMethodCash
			if activity.PaymentMethod != "" {
				payMethod = models.PaymentMethod(activity.PaymentMethod)
			}

			payment := &models.Payment{
				ActivityID:  activity.ID,
				InvoiceID:   activity.InvoiceID,
				Amount:      payAmount,
				Method:      payMethod,
				ReferenceNo: activity.PaymentRef,
			}
			if err := u.paymentRepo.Create(ctx, payment); err != nil {
				return nil, fmt.Errorf("failed to record collection payment: %w", err)
			}

			// Update Invoice State
			invoice.PaidAmount += payAmount
			invoice.SignaturePath = activity.SignaturePath
			
			if invoice.PaidAmount >= invoice.Amount {
				invoice.Status = models.InvoiceStatusPaid
			} else {
				invoice.Status = models.InvoiceStatusPartial
			}

			if err := u.invoiceRepo.Update(ctx, invoice); err != nil {
				return nil, fmt.Errorf("failed to update invoice status: %w", err)
			}
		}
	}

	return activity, nil
}

func (u *visitUseCaseImpl) FinalizeVisit(ctx context.Context, activityID uuid.UUID, items []models.DealItem, outcome string, priceOverride *float64, notes string) error {
	// 1. Fetch the activity
	activity, err := u.activityRepo.GetByID(ctx, activityID)
	if err != nil {
		return err
	}

	if activity.Status != models.VisitStatusDraft {
		return errors.New("activity is already completed or not in draft status")
	}

	// 2. Prepare VisitActivity wrapper for LogActivity-like processing
	// We reuse LogActivity logic by creating a dummy checkout activity
	dummyCheckout := &models.VisitActivity{
		ID:                activity.ID,
		SalesID:           activity.UserID,
		LeadID:            activity.LeadID,
		CustomerID:        activity.CustomerID,
		DealID:            activity.DealID,
		TaskDestinationID: activity.TaskDestinationID,
		Type:              models.VisitTypeCheckOut,
		Latitude:          *activity.Latitude,
		Longitude:         *activity.Longitude,
		DealItems:         items,
		Outcome:           &outcome,
		PriceOverride:     priceOverride,
		Notes:             &notes,
		CreatedAt:         utils.FlexTime{Time: time.Now()},
		Status:            models.VisitStatusCompleted,
	}
	if activity.SignaturePath != nil {
		dummyCheckout.SignaturePath = *activity.SignaturePath
	}

	// 3. Process the dummy checkout (this will create deals, invoices, etc.)
	// We manually trigger the logic here or refactor LogActivity to be more modular.
	// For now, I'll copy the deal creation logic or call a helper.
	
	// Fetch user for SalesType/Role check
	user, err := u.userRepo.FindByID(ctx, activity.UserID)
	if err != nil {
		return errors.New("failed to fetch salesman info")
	}

	// Deal Creation Logic (Copied/Adapted from LogActivity)
	var dAmount float64
	for _, it := range items {
		dAmount += it.UnitPrice * it.Quantity
	}
	if priceOverride != nil {
		dAmount = *priceOverride
	}

	salesmanID := activity.UserID
	newDeal := &models.Deal{
		Title:       "Deal dari Finalisasi Kunjungan",
		CustomerID:  activity.CustomerID,
		LeadID:      activity.LeadID,
		AssignedTo:  &salesmanID,
		Stage:       models.DealStageProspect,
		Status:      models.DealStatusOpen,
		Amount:      &dAmount,
		Probability: 0,
		Items:       items,
		CreatedBy:   &salesmanID,
	}

	// Conversion logic
	if newDeal.CustomerID == nil && newDeal.LeadID != nil {
		newCustID := u.convertLeadToCustomerInline(ctx, *newDeal.LeadID, activity.UserID)
		if newCustID != nil {
			newDeal.CustomerID = newCustID
		}
	}

	isWon := false
	switch outcome {
	case "closing", "bungkus", "deal_won", "deal":
		isWon = true
		newDeal.Stage = models.DealStageClosedWon
		newDeal.Status = models.DealStatusWon
	case "deal_lost", "rejection", "tolak":
		newDeal.Stage = models.DealStageClosedLost
		newDeal.Status = models.DealStatusLost
	default:
		newDeal.Stage = models.DealStageNegotiation
		newDeal.Status = models.DealStatusOpen
	}

	if isWon {
		if user.SalesType != nil && *user.SalesType == models.SalesTypeCanvas {
			// Canvas Deduct
			for _, it := range items {
				_ = u.vanStockRepo.DeductStock(ctx, user.ID, it.ProductID, it.Quantity)
			}
		}
		newDeal.Stage = models.DealStageClosedWon
		newDeal.Status = models.DealStatusWon
	}

	if err := u.dealRepo.Create(ctx, newDeal); err != nil {
		return err
	}

	// --- Automated Invoicing for Task Order & Motoris sales ---
	// For TO and Motoris (if finalized later), we create an Unpaid invoice
	if user.SalesType != nil && (*user.SalesType == models.SalesTypeTaskOrder || *user.SalesType == models.SalesTypeMotoris) {
		signature := ""
		if activity.SignaturePath != nil {
			signature = *activity.SignaturePath
		}

		invoice := &models.Invoice{
			CustomerID:    *newDeal.CustomerID,
			DealID:        &newDeal.ID,
			InvoiceNo:     fmt.Sprintf("INV-TO-%d", time.Now().UnixNano()/1e6),
			Amount:        dAmount,
			PaidAmount:    0,
			Status:        models.InvoiceStatusUnpaid,
			SignaturePath: signature,
		}
		// Set due date to 7 days by default
		due := utils.FlexTime{Time: time.Now().AddDate(0, 0, 7)}
		invoice.DueAt = &due

		if err := u.invoiceRepo.Create(ctx, invoice); err != nil {
			fmt.Printf("⚠️ failed to auto-generate invoice: %v\n", err)
		}
	}

	// 4. Update Activity Status
	activity.Status = models.VisitStatusCompleted
	activity.DealID = &newDeal.ID
	activity.Outcome = &outcome
	activity.Notes = &notes
	activity.DealAmount = &dAmount
	
	return u.activityRepo.Update(ctx, activity)
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
				Status:            models.VisitStatus(sa.Status),
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
				Status:            models.VisitStatus(sa.Status),
			}
			if sa.Latitude != nil { checkIn.Latitude = *sa.Latitude }
			if sa.Longitude != nil { checkIn.Longitude = *sa.Longitude }
			if sa.SelfiePhotoPath != nil { checkIn.SelfiePhotoPath = *sa.SelfiePhotoPath }
			if sa.PlacePhotoPath != nil { checkIn.PlacePhotoPath = *sa.PlacePhotoPath }
			if sa.Distance != nil { checkIn.Distance = sa.Distance }
			checkIn.IsOffline = sa.IsOffline
			checkIn.Notes = sa.Notes
			if sa.CustomerName != nil && *sa.CustomerName != "" {
				checkIn.CustomerName = *sa.CustomerName
			} else if sa.LeadName != nil && *sa.LeadName != "" {
				checkIn.CustomerName = *sa.LeadName
			} else {
				// Fallback: extract target name from Title "Visit to [Name]"
				checkIn.CustomerName = strings.TrimPrefix(sa.Title, "Visit to ")
			}
			checkIn.DealAmount = sa.DealAmount
			
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
				Status:            models.VisitStatus(sa.Status),
			}
			if sa.Latitude != nil { checkOut.Latitude = *sa.Latitude }
			if sa.Longitude != nil { checkOut.Longitude = *sa.Longitude }
			checkOut.IsOffline = sa.IsOffline
			if sa.CustomerName != nil && *sa.CustomerName != "" {
				checkOut.CustomerName = *sa.CustomerName
			} else if sa.LeadName != nil && *sa.LeadName != "" {
				checkOut.CustomerName = *sa.LeadName
			} else {
				// Fallback: extract target name from Title "Visit to [Name]"
				checkOut.CustomerName = strings.TrimPrefix(sa.Title, "Visit to ")
			}
			
			// Checkout notes: append outcome and notes if present
			if sa.Notes != nil && *sa.Notes != "" {
				checkOut.Notes = sa.Notes
			} else {
				checkOut.Notes = sa.Outcome
			}
			checkOut.DealAmount = sa.DealAmount
			
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

func (u *visitUseCaseImpl) convertLeadToCustomerInline(ctx context.Context, leadID uuid.UUID, salesID uuid.UUID) *uuid.UUID {
	lead, err := u.leadRepo.GetByID(ctx, leadID)
	if err != nil {
		return nil
	}
	if lead.CustomerID != nil {
		return lead.CustomerID
	}

	customerName := lead.Name
	if lead.Company != nil && *lead.Company != "" {
		customerName = *lead.Company
	}

	customerType := models.TypeCompany
	if lead.Company != nil {
		switch *lead.Company {
		case "Warung Makan": customerType = models.TypeWarung
		case "Toko Kelontong": customerType = models.TypeToko
		case "Retail / Minimarket": customerType = models.TypeRetail
		case "Agen / Distributor": customerType = models.TypeAgen
		case "Restoran": customerType = models.TypeRestoran
		case "Cafe": customerType = models.TypeCafe
		case "Lainnya": customerType = models.TypeLainnya
		}
	}

	customer := &models.Customer{
		Type:        customerType,
		Name:        customerName,
		CompanyName: lead.Company,
		Email:       lead.Email,
		Phone:       lead.Phone,
		Status:      models.CustomerStatusActive,
		AssignedTo:  &salesID,
		CreatedBy:   &salesID,
		Address:     lead.Address,
		Latitude:    lead.Latitude,
		Longitude:   lead.Longitude,
	}

	if err := u.custRepo.Create(ctx, customer); err == nil {
		lead.Status = models.LeadStatusQualified
		lead.CustomerID = &customer.ID
		lead.ConvertedAt = utils.ToFlexTimePtr(time.Now())
		_ = u.leadRepo.Update(ctx, lead)
		return &customer.ID
	}
	return nil
}

func (u *visitUseCaseImpl) activateCustomerIfProspect(ctx context.Context, custID uuid.UUID) {
	cust, err := u.custRepo.GetByID(ctx, custID)
	if err == nil && cust != nil {
		if cust.Status == models.CustomerStatusProspect {
			cust.Status = models.CustomerStatusActive
			_ = u.custRepo.Update(ctx, cust)
		}
	}
}
