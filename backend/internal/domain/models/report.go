package models

type KpiSummary struct {
	TotalCustomers   int     `json:"total_customers"`
	TotalActiveDeals int     `json:"total_active_deals"`
	PipelineValue    float64 `json:"pipeline_value"`
	WinRate          float64 `json:"win_rate"`
	TotalVisitsToday int     `json:"total_visits_today"`

	// Trends & Progress
	CustomersGrowth float64 `json:"customers_growth"`
	WinRateGrowth   float64 `json:"win_rate_growth"`
	VisitsTarget    int     `json:"visits_target"`

	// Flutter-compatible aliases
	TotalSales          float64 `json:"total_sales"`          // = PipelineValue
	NewLeads            int     `json:"new_leads"`             // = leads count this month
	ActiveDeals         int     `json:"active_deals"`          // = TotalActiveDeals
	VisitsToday         int     `json:"visits_today"`          // = TotalVisitsToday
	TargetMetPercentage float64 `json:"target_met_percentage"` // progress %
	MonthlyTarget       float64 `json:"monthly_target"`        // monthly target amount
	MonthlyRevenue      float64 `json:"monthly_revenue"`       // won deals this month
	DaysLeft            int     `json:"days_left"`             // days left in month
	
	NextStop *VisitRecommendation `json:"next_stop"`
}

type ChartData struct {
	Label string  `json:"label"`
	Value float64 `json:"value"`
}

type SalesPerformance struct {
	SalesID          string  `json:"sales_id"`
	SalesName        string  `json:"sales_name"`
	TotalVisits       int     `json:"total_visits"`
	CompletedVisits   int     `json:"completed_visits"`
	ValidCheckins     int     `json:"valid_checkins"`
	Revenue          float64 `json:"revenue"`
}

type VisitRecommendation struct {
	ID              string  `json:"id"`
	Name            string  `json:"name"`
	Type            string  `json:"type"`             // "lead" or "customer"
	Status          string  `json:"status"`           // "new", "stale", "scheduled"
	Priority        string  `json:"priority"`         // "high", "medium", "low"
	Reason          string  `json:"reason"`           // Human-friendly explanation
	LastVisitAt     *string `json:"last_visit_at"`    // ISO date string
	DaysSinceLast   int     `json:"days_since_last"`
	Address         string  `json:"address"`
	Latitude        float64 `json:"latitude"`
	Longitude       float64 `json:"longitude"`

	// Contextual IDs for "Task same as Dashboard" consistency
	LeadID            *string `json:"lead_id,omitempty"`
	CustomerID        *string `json:"customer_id,omitempty"`
	TaskDestinationID *string `json:"task_destination_id,omitempty"`
	DealID            *string `json:"deal_id,omitempty"`
}
