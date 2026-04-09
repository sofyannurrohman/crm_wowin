package models

import (
	"crm_wowin_backend/pkg/utils"
	"github.com/google/uuid"
)

type Banner struct {
	ID         uuid.UUID     `json:"id"`
	SalesID    uuid.UUID     `json:"sales_id"`
	CustomerID *uuid.UUID    `json:"customer_id,omitempty"`
	LeadID     *uuid.UUID    `json:"lead_id,omitempty"`
	ShopName   string        `json:"shop_name"`
	Content    string        `json:"content"`
	Dimensions string        `json:"dimensions"`
	PhotoPath  *string       `json:"photo_path,omitempty"`
	Latitude   float64       `json:"latitude"`
	Longitude  float64       `json:"longitude"`
	Address    *string       `json:"address,omitempty"`
	CreatedAt  utils.FlexTime `json:"created_at"`
	UpdatedAt  utils.FlexTime `json:"updated_at"`
}
