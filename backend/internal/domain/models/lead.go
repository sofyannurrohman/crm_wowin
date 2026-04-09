package models

import (
	"crm_wowin_backend/pkg/utils"

	"github.com/google/uuid"
)

type LeadStatus string

const (
	LeadStatusNew         LeadStatus = "new"
	LeadStatusContacted   LeadStatus = "contacted"
	LeadStatusQualified   LeadStatus = "qualified"
	LeadStatusUnqualified LeadStatus = "unqualified"
)

type LeadSource string

const (
	LeadSourceSurvey      LeadSource = "survey"
	LeadSourceReferral    LeadSource = "referral"
	LeadSourceColdCall    LeadSource = "cold_call"
	LeadSourceSocialMedia LeadSource = "social_media"
	LeadSourceWebsite     LeadSource = "website"
	LeadSourceEvent       LeadSource = "event"
	LeadSourceOther       LeadSource = "other"
)

// Lead represents a raw prospect before standardizing to Customer/Deal
type Lead struct {
	ID             uuid.UUID   `json:"id"`
	Title          string      `json:"title"`
	Name           string      `json:"name"`
	Company        *string     `json:"company,omitempty"`
	Email          *string     `json:"email,omitempty"`
	Phone          *string     `json:"phone,omitempty"`
	Source         LeadSource  `json:"source"`
	Status         LeadStatus  `json:"status"`
	AssignedTo     *uuid.UUID  `json:"sales_id,omitempty"`
	CustomerID        *uuid.UUID  `json:"customer_id,omitempty"` // populated if converted
	EstimatedValue    *float64    `json:"estimated_value,omitempty"`
	PotentialProducts []string    `json:"potential_products,omitempty"`
	Notes             *string     `json:"notes,omitempty"`
	ConvertedAt       *utils.FlexTime `json:"converted_at,omitempty"`
	Address           *string     `json:"address,omitempty"`
	Latitude          *float64    `json:"latitude,omitempty"`
	Longitude         *float64    `json:"longitude,omitempty"`
	CreatedBy      *uuid.UUID  `json:"created_by,omitempty"`
	CreatedAt      utils.FlexTime   `json:"created_at"`
	UpdatedAt      utils.FlexTime   `json:"updated_at"`
}
