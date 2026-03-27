package usecase

import (
	"context"
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"
)

type ReportUseCase interface {
	GetDashboardSummary(ctx context.Context) (*models.KpiSummary, error)
	GetAnalytics(ctx context.Context, months int) (map[string]interface{}, error)
}

type reportUseCaseImpl struct {
	repo       repository.ReportRepository
	targetRepo repository.TargetRepository
}

func NewReportUseCase(repo repository.ReportRepository, targetRepo repository.TargetRepository) ReportUseCase {
	return &reportUseCaseImpl{repo: repo, targetRepo: targetRepo}
}

func (u *reportUseCaseImpl) GetDashboardSummary(ctx context.Context) (*models.KpiSummary, error) {
	summary, err := u.repo.GetKpiSummary(ctx)
	if err != nil {
		return nil, err
	}

	// Fetch targets to show progress
	target, _ := u.targetRepo.Get(ctx)
	if target != nil {
		summary.VisitsTarget = target.MonthlyVisits
	} else {
		summary.VisitsTarget = 150 // Default fallback
	}

	// For now, these trends are hardcoded to backend values but accessible to frontend
	summary.CustomersGrowth = 12.0
	summary.WinRateGrowth = 2.4

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
