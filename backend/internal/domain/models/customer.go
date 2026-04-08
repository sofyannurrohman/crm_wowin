package models

import (
	"crm_wowin_backend/pkg/utils"

	"github.com/google/uuid"
)

type CustomerType string

const (
	TypeIndividual CustomerType = "individual"
	TypeCompany    CustomerType = "company"
	TypeWarung     CustomerType = "warung"
	TypeRetail     CustomerType = "retail"
	TypeToko       CustomerType = "toko"
	TypeAgen       CustomerType = "agen"
	TypeRestoran   CustomerType = "restoran"
	TypeCafe       CustomerType = "cafe"
	TypeLainnya    CustomerType = "lainnya"
)

type CustomerStatus string

const (
	CustomerStatusProspect CustomerStatus = "prospect"
	CustomerStatusActive   CustomerStatus = "active"
	CustomerStatusInactive CustomerStatus = "inactive"
	CustomerStatusChurned  CustomerStatus = "churned"
)

// Customer represents the customers table
type Customer struct {
	ID            uuid.UUID      `json:"id"`
	Code          *string        `json:"code,omitempty"`
	Type          CustomerType   `json:"type"`
	Name          string         `json:"name"`
	CompanyName   *string        `json:"company_name,omitempty"`
	Industry      *string        `json:"industry,omitempty"`
	Website       *string        `json:"website,omitempty"`
	Email         *string        `json:"email,omitempty"`
	Phone         *string        `json:"phone,omitempty"`
	PhoneAlt      *string        `json:"phone_alt,omitempty"`
	Status        CustomerStatus `json:"status"`

	// Address Information
	Address    *string `json:"address,omitempty"`
	City       *string `json:"city,omitempty"`
	Province   *string `json:"province,omitempty"`
	PostalCode *string `json:"postal_code,omitempty"`
	Country    *string `json:"country,omitempty"`

	// Location Information
	Latitude      *float64 `json:"latitude,omitempty"`  // Mapped to/from PostGIS Geography
	Longitude     *float64 `json:"longitude,omitempty"` // Mapped to/from PostGIS Geography
	CheckinRadius int      `json:"checkin_radius"`      // meters

	// Relations
	TerritoryID *uuid.UUID `json:"territory_id,omitempty"`
	AssignedTo  *uuid.UUID `json:"assigned_to,omitempty"`
	CreatedBy   *uuid.UUID `json:"created_by,omitempty"`

	// Financial
	CreditLimit  *float64 `json:"credit_limit,omitempty"`
	PaymentTerms *int     `json:"payment_terms,omitempty"`

	Notes *string `json:"notes,omitempty"`

	CreatedAt utils.FlexTime   `json:"created_at"`
	UpdatedAt utils.FlexTime   `json:"updated_at"`
	DeletedAt *utils.FlexTime `json:"deleted_at,omitempty"`
}

// Contact represents the customer_contacts table
type Contact struct {
	ID         uuid.UUID  `json:"id"`
	CustomerID uuid.UUID  `json:"customer_id"`
	Name       string     `json:"name"`
	Title      *string    `json:"title,omitempty"`
	Department *string    `json:"department,omitempty"`
	Email      *string    `json:"email,omitempty"`
	Phone      *string    `json:"phone,omitempty"`
	PhoneAlt   *string    `json:"phone_alt,omitempty"`
	IsPrimary  bool       `json:"is_primary"`
	Notes      *string    `json:"notes,omitempty"`
	CreatedAt  utils.FlexTime  `json:"created_at"`
	UpdatedAt  utils.FlexTime  `json:"updated_at"`
}
