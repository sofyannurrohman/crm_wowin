package models

type KpiSummary struct {
	TotalCustomers    int     `json:"total_customers"`
	TotalActiveDeals  int     `json:"total_active_deals"`
	PipelineValue    float64 `json:"pipeline_value"`
	WinRate          float64 `json:"win_rate"`
	TotalVisitsToday int     `json:"total_visits_today"`
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
