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
	repo repository.ReportRepository
}

func NewReportUseCase(repo repository.ReportRepository) ReportUseCase {
	return &reportUseCaseImpl{repo: repo}
}

func (u *reportUseCaseImpl) GetDashboardSummary(ctx context.Context) (*models.KpiSummary, error) {
	return u.repo.GetKpiSummary(ctx)
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
