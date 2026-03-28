package postgres

import (
	"context"
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"

	"github.com/jackc/pgx/v5/pgxpool"
)

type reportRepositoryImpl struct {
	db *pgxpool.Pool
}

func NewReportRepository(db *pgxpool.Pool) repository.ReportRepository {
	return &reportRepositoryImpl{db: db}
}

func (r *reportRepositoryImpl) GetKpiSummary(ctx context.Context) (*models.KpiSummary, error) {
	query := `
		SELECT 
			(SELECT COUNT(*) FROM customers WHERE deleted_at IS NULL) as total_customers,
			(SELECT COUNT(*) FROM deals WHERE status = 'open') as active_deals,
			(SELECT COALESCE(SUM(amount), 0) FROM deals WHERE status = 'open') as pipeline_value,
			(SELECT COALESCE(
				(COUNT(*) FILTER (WHERE status = 'won'))::float / NULLIF(COUNT(*), 0) * 100, 0
			 ) FROM deals WHERE status IN ('won', 'lost')) as win_rate,
			(SELECT COUNT(*) FROM visit_activities WHERE type = 'check-in' AND DATE(created_at) = CURRENT_DATE) as visits_today,
			(SELECT COUNT(*) FROM leads WHERE DATE_TRUNC('month', created_at) = DATE_TRUNC('month', CURRENT_DATE)) as new_leads,
			(SELECT COALESCE(SUM(amount), 0) FROM deals WHERE status = 'won' AND DATE_TRUNC('month', closed_at) = DATE_TRUNC('month', CURRENT_DATE)) as monthly_revenue,
			(EXTRACT(DAY FROM (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month') - CURRENT_DATE))::int as days_left
	`
	var k models.KpiSummary
	var daysLeft int
	err := r.db.QueryRow(ctx, query).Scan(
		&k.TotalCustomers, &k.TotalActiveDeals, &k.PipelineValue, &k.WinRate,
		&k.TotalVisitsToday, &k.NewLeads, &k.MonthlyRevenue, &daysLeft,
	)
	if err != nil {
		return nil, err
	}
	// Populate Flutter-compatible aliases
	k.ActiveDeals = k.TotalActiveDeals
	k.VisitsToday = k.TotalVisitsToday
	k.TotalSales = k.PipelineValue
	k.DaysLeft = daysLeft
	return &k, nil
}


func (r *reportRepositoryImpl) GetRevenueTrend(ctx context.Context, months int) ([]models.ChartData, error) {
	query := `
		SELECT 
			TO_CHAR(closed_at, 'Mon') as label,
			SUM(amount) / 1000000 as value
		FROM deals
		WHERE status = 'won' AND closed_at >= NOW() - INTERVAL '1 month' * $1
		GROUP BY TO_CHAR(closed_at, 'Mon'), DATE_TRUNC('month', closed_at)
		ORDER BY DATE_TRUNC('month', closed_at)
	`
	rows, err := r.db.Query(ctx, query, months)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var result []models.ChartData
	for rows.Next() {
		var d models.ChartData
		if err := rows.Scan(&d.Label, &d.Value); err != nil {
			return nil, err
		}
		result = append(result, d)
	}
	return result, nil
}

func (r *reportRepositoryImpl) GetPipelineFunnel(ctx context.Context) ([]models.ChartData, error) {
	query := `
		SELECT stage::text as label, COUNT(*) as value
		FROM deals
		WHERE status = 'open'
		GROUP BY stage
		ORDER BY MIN(created_at)
	`
	rows, err := r.db.Query(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var result []models.ChartData
	for rows.Next() {
		var d models.ChartData
		if err := rows.Scan(&d.Label, &d.Value); err != nil {
			return nil, err
		}
		result = append(result, d)
	}
	return result, nil
}

func (r *reportRepositoryImpl) GetTopPerformers(ctx context.Context, limit int) ([]models.SalesPerformance, error) {
	// Using the MV if available or simple join
	query := `
		SELECT 
			u.id::text, u.name, 
			COUNT(v.id) as total_visits,
			COUNT(v.id) as completed,
			COUNT(v.id) FILTER (WHERE v.distance <= 100) as valid,
			COALESCE(SUM(d.amount) FILTER (WHERE d.status = 'won'), 0) as revenue
		FROM users u
		LEFT JOIN visit_activities v ON v.sales_id = u.id AND v.type = 'check-in' AND v.created_at >= DATE_TRUNC('month', CURRENT_DATE)
		LEFT JOIN deals d ON d.assigned_to = u.id AND d.status = 'won' AND d.closed_at >= DATE_TRUNC('month', CURRENT_DATE)
		WHERE u.role = 'sales'
		GROUP BY u.id, u.name
		ORDER BY revenue DESC
		LIMIT $1
	`
	rows, err := r.db.Query(ctx, query, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var result []models.SalesPerformance
	for rows.Next() {
		var s models.SalesPerformance
		if err := rows.Scan(&s.SalesID, &s.SalesName, &s.TotalVisits, &s.CompletedVisits, &s.ValidCheckins, &s.Revenue); err != nil {
			return nil, err
		}
		result = append(result, s)
	}
	return result, nil
}
