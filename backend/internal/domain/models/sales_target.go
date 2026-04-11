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
	TargetRevenue      float64   `json:"target_revenue"`
	TargetVisits       int       `json:"target_visits"`
	TargetDeals        int       `json:"target_deals"`
	TargetNewCustomers int       `json:"target_new_customers"`
	WinRate            float64   `json:"win_rate"`
	CreatedAt          time.Time `json:"created_at"`
	UpdatedAt          time.Time `json:"updated_at"`
}
