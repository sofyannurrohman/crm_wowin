package usecase

import (
	"context"
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"
	"time"

	"github.com/google/uuid"
)

type ReportUseCase interface {
	GetDashboardSummary(ctx context.Context, salesID string, role string) (*models.KpiSummary, error)
	GetAnalytics(ctx context.Context, months int) (map[string]interface{}, error)
	GetVisitRecommendations(ctx context.Context, salesID string) ([]models.VisitRecommendation, error)
}

type reportUseCaseImpl struct {
	repo            repository.ReportRepository
	targetRepo      repository.TargetRepository
	salesTargetRepo repository.SalesTargetRepository
	taskRepo        repository.TaskRepository
}

func NewReportUseCase(repo repository.ReportRepository, targetRepo repository.TargetRepository, salesTargetRepo repository.SalesTargetRepository, taskRepo repository.TaskRepository) ReportUseCase {
	return &reportUseCaseImpl{repo: repo, targetRepo: targetRepo, salesTargetRepo: salesTargetRepo, taskRepo: taskRepo}
}

func (u *reportUseCaseImpl) GetDashboardSummary(ctx context.Context, salesID string, role string) (*models.KpiSummary, error) {
	summary, err := u.repo.GetKpiSummary(ctx, salesID, role)
	if err != nil {
		return nil, err
	}

	// Fetch targets: Individual (SalesTarget) first, fallback to Global (Target)
	uid, _ := uuid.Parse(salesID)
	// We use current month and year for dashboard summary
	now := time.Now()
	month := int(now.Month())
	year := now.Year()

	var targetRevenue float64
	var targetVisits int

	individualTarget, err := u.salesTargetRepo.GetByUserID(ctx, uid, month, year)
	if err == nil && individualTarget != nil {
		targetRevenue = individualTarget.TargetRevenue
		targetVisits = individualTarget.TargetVisits
	} else {
		// Fallback to Global Target
		globalTarget, _ := u.targetRepo.Get(ctx)
		if globalTarget != nil {
			targetRevenue = float64(globalTarget.MonthlyRevenue)
			targetVisits = globalTarget.MonthlyVisits
		} else {
			targetRevenue = 500000000 // default fallback
			targetVisits = 150
		}
	}

	summary.VisitsTarget = targetVisits
	summary.MonthlyTarget = targetRevenue

	// Compute target percentage
	if summary.MonthlyTarget > 0 {
		summary.TargetMetPercentage = (summary.MonthlyRevenue / summary.MonthlyTarget) * 100
		if summary.TargetMetPercentage > 100 {
			summary.TargetMetPercentage = 100
		}
	}

	// Static growth trends
	summary.CustomersGrowth = 12.0
	summary.WinRateGrowth = 2.4

	// --- NEXT STOP LOGIC ---
	// Fetch today's tasks for this salesman
	uid, _ = uuid.Parse(salesID)
	tasks, err := u.taskRepo.List(ctx, repository.TaskFilter{
		SalesID: &uid,
	})
	if err == nil && len(tasks) > 0 {
		var nextStop *models.TaskDestination
		// Look for the first uncompleted destination in active tasks today
		for i := range tasks {
			if tasks[i].Status == models.TaskStatusCompleted {
				continue
			}
			for j := range tasks[i].Destinations {
				dest := &tasks[i].Destinations[j]
				if dest.Status != models.TaskStatusCompleted {
					if nextStop == nil || dest.SequenceOrder < nextStop.SequenceOrder {
						nextStop = dest
					}
				}
			}
		}

		if nextStop != nil {
			targetName := "Unknown"
			if nextStop.TargetName != nil {
				targetName = *nextStop.TargetName
			}
			rec := &models.VisitRecommendation{
				ID:       nextStop.ID.String(),
				Name:     targetName,
				Priority: string(nextStop.Status),
				Reason:   "Destinasi berikutnya sesuai rute Anda hari ini.",
			}
			if nextStop.TargetAddress != nil {
				rec.Address = *nextStop.TargetAddress
			}
			if nextStop.TargetLatitude != nil {
				rec.Latitude = *nextStop.TargetLatitude
			}
			if nextStop.TargetLongitude != nil {
				rec.Longitude = *nextStop.TargetLongitude
			}

			// Add Check-In Context
			taskDestinationID := nextStop.ID.String()
			rec.TaskDestinationID = &taskDestinationID
			if nextStop.CustomerID != nil && *nextStop.CustomerID != uuid.Nil {
				cid := nextStop.CustomerID.String()
				rec.CustomerID = &cid
				rec.Type = "customer"
			}
			if nextStop.LeadID != nil && *nextStop.LeadID != uuid.Nil {
				lid := nextStop.LeadID.String()
				rec.LeadID = &lid
				rec.Type = "lead"
			}
			if nextStop.DealID != nil && *nextStop.DealID != uuid.Nil {
				did := nextStop.DealID.String()
				rec.DealID = &did
			}

			summary.NextStop = rec
		}
	}

	return summary, nil
}


func (u *reportUseCaseImpl) GetAnalytics(ctx context.Context, months int) (map[string]interface{}, error) {
	revenue, _ := u.repo.GetRevenueTrend(ctx, months)
	funnel, _ := u.repo.GetPipelineFunnel(ctx)
	top, _ := u.repo.GetTopPerformers(ctx, 5)

	return map[string]interface{}{
		"revenue_trend": revenue,
		"pipeline_funnel": funnel,
		"top_performers": top,
	}, nil
}

func (u *reportUseCaseImpl) GetVisitRecommendations(ctx context.Context, salesID string) ([]models.VisitRecommendation, error) {
	return u.repo.GetVisitRecommendations(ctx, salesID)
}
