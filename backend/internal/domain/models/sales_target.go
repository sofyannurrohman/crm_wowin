package models

import (
	"time"

	"github.com/google/uuid"
)

type SalesTarget struct {
	ID                 uuid.UUID `json:"id"`
	UserID             uuid.UUID `json:"user_id"`
	PeriodYear         int       `json:"period_year"`
	PeriodMonth        int       `json:"period_month"`
	TargetRevenue      float64   `json:"monthly_revenue"`
	TargetVisits       int       `json:"monthly_visits"`
	TargetDeals        int       `json:"monthly_deals"`
	TargetNewCustomers int       `json:"monthly_new_customers"`
	WinRate            float64   `json:"win_rate"`
	CreatedAt          time.Time `json:"created_at"`
	UpdatedAt          time.Time `json:"updated_at"`
}
