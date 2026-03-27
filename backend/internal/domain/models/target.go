package models

import "time"

type Target struct {
	MonthlyRevenue      int64     `json:"monthly_revenue"`
	MonthlyVisits       int       `json:"monthly_visits"`
	MonthlyNewCustomers int       `json:"monthly_new_customers"`
	WinRate             float64   `json:"win_rate"`
	MonthlyDeals       int       `json:"monthly_deals"`
	UpdatedAt           time.Time `json:"updated_at"`
}
