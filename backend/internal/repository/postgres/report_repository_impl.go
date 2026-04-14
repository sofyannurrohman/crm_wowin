package postgres

import (
	"context"
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"
	"crm_wowin_backend/pkg/utils"

	"github.com/jackc/pgx/v5/pgxpool"
)

type reportRepositoryImpl struct {
	db *pgxpool.Pool
}

func NewReportRepository(db *pgxpool.Pool) repository.ReportRepository {
	return &reportRepositoryImpl{db: db}
}

func (r *reportRepositoryImpl) GetKpiSummary(ctx context.Context, salesID string, role string) (*models.KpiSummary, error) {
	// Base filters
	isSales := role == "sales"
	
	query := `
		WITH kpi AS (
			SELECT 
				-- Customers
				(SELECT COUNT(*) FROM customers WHERE deleted_at IS NULL` + utils.If(isSales, ` AND assigned_to = $1`, "") + `) as total_customers,
				
				-- Deals (Active & Pipeline)
				(SELECT COUNT(*) FROM deals WHERE status = 'open'` + utils.If(isSales, ` AND assigned_to = $1`, "") + `) as active_deals,
				(SELECT COALESCE(SUM(amount), 0) FROM deals WHERE status = 'open'` + utils.If(isSales, ` AND assigned_to = $1`, "") + `) as pipeline_value,
				(SELECT COALESCE(
					(COUNT(*) FILTER (WHERE status = 'won'))::float / NULLIF(COUNT(*), 0) * 100, 0
				 ) FROM deals WHERE status IN ('won', 'lost')` + utils.If(isSales, ` AND assigned_to = $1`, "") + `) as win_rate,
				
				-- Bookings (Deals Won)
				(SELECT COALESCE(SUM(amount), 0) FROM deals WHERE status = 'won' AND DATE_TRUNC('month', closed_at) = DATE_TRUNC('month', CURRENT_DATE)` + utils.If(isSales, ` AND assigned_to = $1`, "") + `) as monthly_booking,
				(SELECT COALESCE(SUM(amount), 0) FROM deals WHERE status = 'won' AND DATE(closed_at) = CURRENT_DATE` + utils.If(isSales, ` AND assigned_to = $1`, "") + `) as today_booking,

				-- Revenue (Invoices Issued)
				(SELECT COALESCE(SUM(amount), 0) FROM invoices i 
				 JOIN customers c ON i.customer_id = c.id
				 WHERE DATE_TRUNC('month', i.created_at) = DATE_TRUNC('month', CURRENT_DATE)` + utils.If(isSales, ` AND c.assigned_to = $1`, "") + `) as monthly_revenue,

				-- Collection (Paid Amount from Invoices / Payments)
				(SELECT COALESCE(SUM(p.amount), 0) FROM payments p
				 JOIN sales_activities sa ON p.activity_id = sa.id
				 WHERE DATE_TRUNC('month', p.created_at) = DATE_TRUNC('month', CURRENT_DATE)` + utils.If(isSales, ` AND sa.user_id = $1`, "") + `) as monthly_collection,
				(SELECT COALESCE(SUM(p.amount), 0) FROM payments p
				 JOIN sales_activities sa ON p.activity_id = sa.id
				 WHERE DATE(p.created_at) = CURRENT_DATE` + utils.If(isSales, ` AND sa.user_id = $1`, "") + `) as today_collection,

				-- Others
				(SELECT COUNT(*) FROM visits WHERE DATE(checkin_at) = CURRENT_DATE` + utils.If(isSales, ` AND sales_id = $1`, "") + `) as visits_today,
				(SELECT COUNT(*) FROM leads WHERE DATE_TRUNC('month', created_at) = DATE_TRUNC('month', CURRENT_DATE)` + utils.If(isSales, ` AND assigned_to = $1`, "") + `) as new_leads,
				(EXTRACT(DAY FROM (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month') - CURRENT_DATE))::int as days_left
		)
		SELECT * FROM kpi
	`

	var k models.KpiSummary
	var daysLeft int
	var monthlyBooking, monthlyCollection float64
	
	var err error
	if isSales {
		err = r.db.QueryRow(ctx, query, salesID).Scan(
			&k.TotalCustomers, &k.TotalActiveDeals, &k.PipelineValue, &k.WinRate,
			&monthlyBooking, &k.TodayBooking, &k.MonthlyRevenue,
			&monthlyCollection, &k.TodayCollection,
			&k.TotalVisitsToday, &k.NewLeads, &daysLeft,
		)
	} else {
		err = r.db.QueryRow(ctx, query).Scan(
			&k.TotalCustomers, &k.TotalActiveDeals, &k.PipelineValue, &k.WinRate,
			&monthlyBooking, &k.TodayBooking, &k.MonthlyRevenue,
			&monthlyCollection, &k.TodayCollection,
			&k.TotalVisitsToday, &k.NewLeads, &daysLeft,
		)
	}
	
	if err != nil {
		return nil, err
	}

	// Populate aliases and computed fields
	k.ActiveDeals = k.TotalActiveDeals
	k.VisitsToday = k.TotalVisitsToday
	k.TotalSales = k.PipelineValue
	k.TotalBooking = monthlyBooking
	k.TotalCollection = monthlyCollection
	k.DaysLeft = daysLeft
	
	return &k, nil
}


func (r *reportRepositoryImpl) GetRevenueTrend(ctx context.Context, months int) ([]models.ChartData, error) {
	query := `
		SELECT 
			TO_CHAR(created_at, 'Mon') as label,
			SUM(amount) / 1000000 as value
		FROM invoices
		WHERE created_at >= NOW() - INTERVAL '1 month' * $1
		GROUP BY TO_CHAR(created_at, 'Mon'), DATE_TRUNC('month', created_at)
		ORDER BY DATE_TRUNC('month', created_at)
	`
	rows, err := r.db.Query(ctx, query, months)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	result := []models.ChartData{}
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

	result := []models.ChartData{}
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
			COUNT(DISTINCT v.id) as total_visits,
			COUNT(DISTINCT v.id) as completed,
			COUNT(DISTINCT v.id) FILTER (WHERE v.checkin_distance <= 100) as valid,
			COALESCE(SUM(i.amount), 0) as revenue
		FROM users u
		LEFT JOIN visits v ON v.sales_id = u.id AND v.checkin_at >= DATE_TRUNC('month', CURRENT_DATE)
		LEFT JOIN (
			SELECT i.amount, c.assigned_to, i.created_at
			FROM invoices i
			JOIN customers c ON i.customer_id = c.id
		) i ON i.assigned_to = u.id AND i.created_at >= DATE_TRUNC('month', CURRENT_DATE)
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

	result := []models.SalesPerformance{}
	for rows.Next() {
		var s models.SalesPerformance
		if err := rows.Scan(&s.SalesID, &s.SalesName, &s.TotalVisits, &s.CompletedVisits, &s.ValidCheckins, &s.Revenue); err != nil {
			return nil, err
		}
		result = append(result, s)
	}
	return result, nil
}

func (r *reportRepositoryImpl) GetVisitRecommendations(ctx context.Context, salesID string) ([]models.VisitRecommendation, error) {
	query := `
		WITH last_visits AS (
			SELECT 
				customer_id, 
				MAX(checkin_at) as last_visit_at
			FROM visits
			GROUP BY customer_id
		)
		SELECT * FROM (
			SELECT 
				l.id::text, 
				l.title as name, 
				'lead' as type,
				CASE 
					WHEN lv.last_visit_at IS NULL THEN 'new'
					ELSE 'stale'
				END as status,
				CASE 
					WHEN lv.last_visit_at IS NULL THEN 'high'
					WHEN lv.last_visit_at < NOW() - INTERVAL '21 days' THEN 'medium'
					ELSE 'low'
				END as priority,
				CASE 
					WHEN lv.last_visit_at IS NULL THEN 'Lead baru butuh kunjungan pertama'
					ELSE 'Sudah ' || EXTRACT(DAY FROM NOW() - lv.last_visit_at)::int || ' hari tanpa kontak'
				END as reason,
				TO_CHAR(lv.last_visit_at, 'YYYY-MM-DD"T"HH24:MI:SS"Z"') as last_visit_at,
				COALESCE(EXTRACT(DAY FROM NOW() - lv.last_visit_at)::int, 0) as days_since_last,
				COALESCE(c.address, '') as address,
				COALESCE(ST_Y(c.location::geometry), 0) as latitude,
				COALESCE(ST_X(c.location::geometry), 0) as longitude
			FROM leads l
			LEFT JOIN customers c ON l.customer_id = c.id
			LEFT JOIN last_visits lv ON l.customer_id = lv.customer_id
			WHERE l.assigned_to = $1 AND l.status != 'converted'
			
			UNION ALL
			
			SELECT 
				c.id::text, 
				c.name, 
				'customer' as type,
				CASE 
					WHEN lv.last_visit_at IS NULL THEN 'new'
					ELSE 'stale'
				END as status,
				CASE 
					WHEN lv.last_visit_at IS NULL THEN 'high'
					WHEN lv.last_visit_at < NOW() - INTERVAL '21 days' THEN 'medium'
					ELSE 'low'
				END as priority,
				CASE 
					WHEN lv.last_visit_at IS NULL THEN 'Pelanggan baru belum pernah dikunjungi'
					ELSE 'Akun stagnan: ' || EXTRACT(DAY FROM NOW() - lv.last_visit_at)::int || ' hari tanpa kontak'
				END as reason,
				TO_CHAR(lv.last_visit_at, 'YYYY-MM-DD"T"HH24:MI:SS"Z"') as last_visit_at,
				COALESCE(EXTRACT(DAY FROM NOW() - lv.last_visit_at)::int, 0) as days_since_last,
				COALESCE(c.address, '') as address,
				COALESCE(ST_Y(c.location::geometry), 0) as latitude,
				COALESCE(ST_X(c.location::geometry), 0) as longitude
			FROM customers c
			LEFT JOIN last_visits lv ON c.id = lv.customer_id
			WHERE c.assigned_to = $1 AND c.id NOT IN (SELECT customer_id FROM leads WHERE customer_id IS NOT NULL)
		) as sub
		ORDER BY 
			CASE WHEN priority = 'high' THEN 1 WHEN priority = 'medium' THEN 2 ELSE 3 END ASC,
			days_since_last DESC NULLS FIRST
		LIMIT 5
	`
	rows, err := r.db.Query(ctx, query, salesID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	result := []models.VisitRecommendation{}
	for rows.Next() {
		var v models.VisitRecommendation
		err := rows.Scan(
			&v.ID, &v.Name, &v.Type, &v.Status, &v.Priority, &v.Reason,
			&v.LastVisitAt, &v.DaysSinceLast, &v.Address, &v.Latitude, &v.Longitude,
		)
		if err != nil {
			return nil, err
		}
		result = append(result, v)
	}
	return result, nil
}
