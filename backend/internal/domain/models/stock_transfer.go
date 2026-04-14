package models

import (
	"crm_wowin_backend/pkg/utils"
	"github.com/google/uuid"
)

type StockTransferType string

const (
	StockTransferTypeLoading   StockTransferType = "loading"
	StockTransferTypeUnloading StockTransferType = "unloading"
)

type StockTransferStatus string

const (
	StockTransferStatusPending   StockTransferStatus = "pending"
	StockTransferStatusConfirmed StockTransferStatus = "confirmed"
	StockTransferStatusRejected  StockTransferStatus = "rejected"
)

type StockTransfer struct {
	ID          uuid.UUID           `json:"id"`
	WarehouseID uuid.UUID           `json:"warehouse_id"`
	SalesID     uuid.UUID           `json:"sales_id"`
	Type        StockTransferType   `json:"type"`
	Status      StockTransferStatus `json:"status"`
	Notes       *string             `json:"notes,omitempty"`
	CreatedAt   utils.FlexTime      `json:"created_at"`
	UpdatedAt   utils.FlexTime      `json:"updated_at"`
	
	Items []*StockTransferItem `json:"items,omitempty"`
}

type StockTransferItem struct {
	ID         uuid.UUID `json:"id"`
	TransferID uuid.UUID `json:"transfer_id"`
	ProductID  uuid.UUID `json:"product_id"`
	Quantity   float64   `json:"quantity"`
    CreatedAt  utils.FlexTime `json:"created_at"`
}
