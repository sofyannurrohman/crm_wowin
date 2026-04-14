package models

import (
	"crm_wowin_backend/pkg/utils"
	"github.com/google/uuid"
)

type InvoiceStatus string

const (
	InvoiceStatusUnpaid    InvoiceStatus = "unpaid"
	InvoiceStatusPartial   InvoiceStatus = "partial"
	InvoiceStatusPaid      InvoiceStatus = "paid"
	InvoiceStatusCancelled InvoiceStatus = "cancelled"
)

type Invoice struct {
	ID            uuid.UUID       `json:"id"`
	CustomerID    uuid.UUID       `json:"customer_id"`
	DealID        *uuid.UUID      `json:"deal_id,omitempty"`
	InvoiceNo     string          `json:"invoice_no"`
	Amount        float64         `json:"amount"`
	PaidAmount    float64         `json:"paid_amount"`
	Status        InvoiceStatus   `json:"status"`
	SignaturePath string          `json:"signature_path,omitempty"`
	DueAt         *utils.FlexTime `json:"due_at,omitempty"`
	CreatedAt     utils.FlexTime  `json:"created_at"`
	UpdatedAt     utils.FlexTime  `json:"updated_at"`
	
	// Detail items (optional)
	Items []*InvoiceItem `json:"items,omitempty"`
}

type InvoiceItem struct {
	ID        uuid.UUID `json:"id"`
	InvoiceID uuid.UUID `json:"invoice_id"`
	ProductID uuid.UUID `json:"product_id"`
	Name      string    `json:"name"`
	Quantity  float64   `json:"quantity"`
	Unit      string    `json:"unit"`
	UnitPrice float64   `json:"unit_price"`
	Subtotal  float64   `json:"subtotal"`
    CreatedAt utils.FlexTime `json:"created_at"`
}
