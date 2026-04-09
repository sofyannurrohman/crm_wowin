package usecase

import (
	"context"
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"
	"github.com/google/uuid"
)

type ReportUseCase interface {
	GetDashboardSummary(ctx context.Context, salesID string) (*models.KpiSummary, error)
	GetAnalytics(ctx context.Context, months int) (map[string]interface{}, error)
	GetVisitRecommendations(ctx context.Context, salesID string) ([]models.VisitRecommendation, error)
}

type reportUseCaseImpl struct {
	repo       repository.ReportRepository
	targetRepo repository.TargetRepository
	taskRepo   repository.TaskRepository
}

func NewReportUseCase(repo repository.ReportRepository, targetRepo repository.TargetRepository, taskRepo repository.TaskRepository) ReportUseCase {
	return &reportUseCaseImpl{repo: repo, targetRepo: targetRepo, taskRepo: taskRepo}
}

func (u *reportUseCaseImpl) GetDashboardSummary(ctx context.Context, salesID string) (*models.KpiSummary, error) {
	summary, err := u.repo.GetKpiSummary(ctx)
	if err != nil {
		return nil, err
	}

	// Fetch targets to show progress
	target, _ := u.targetRepo.Get(ctx)
	if target != nil {
		summary.VisitsTarget = target.MonthlyVisits
		summary.MonthlyTarget = float64(target.MonthlyRevenue)
	} else {
		summary.VisitsTarget = 150 // Default fallback
		summary.MonthlyTarget = 65000
	}

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
	uid, _ := uuid.Parse(salesID)
	tasks, err := u.taskRepo.List(ctx, repository.TaskFilter{
		SalesID: &uid,
	})
	if err == nil && len(tasks) > 0 {
		var nextStop *models.TaskDestination
		// Look for the first uncompleted destination in today's tasks
		for i := range tasks {
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
