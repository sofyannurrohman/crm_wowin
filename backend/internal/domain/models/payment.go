package models

import (
	"time"

	"github.com/google/uuid"
)

type PaymentMethod string

const (
	PaymentMethodCash     PaymentMethod = "cash"
	PaymentMethodTransfer PaymentMethod = "transfer"
	PaymentMethodCredit   PaymentMethod = "credit"
)

// Payment represents a manual payment recorded during a visit
type Payment struct {
	ID          uuid.UUID     `json:"id"`
	ActivityID  uuid.UUID     `json:"activity_id"`
	Amount      float64       `json:"amount"`
	Method      PaymentMethod `json:"method"`
	ReferenceNo *string       `json:"reference_no,omitempty"`
	PhotoPath   *string       `json:"photo_path,omitempty"`
	CreatedAt   time.Time     `json:"created_at"`
}
