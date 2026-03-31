package repository

import (
	"context"
	"crm_wowin_backend/internal/domain/models"
)

type ReportRepository interface {
	GetKpiSummary(ctx context.Context) (*models.KpiSummary, error)
	GetRevenueTrend(ctx context.Context, months int) ([]models.ChartData, error)
	GetPipelineFunnel(ctx context.Context) ([]models.ChartData, error)
	GetTopPerformers(ctx context.Context, limit int) ([]models.SalesPerformance, error)
	GetVisitRecommendations(ctx context.Context, salesID string) ([]models.VisitRecommendation, error)
}
