package models

import (
	"crm_wowin_backend/pkg/utils"

	"github.com/google/uuid"
)

type DealStage string

const (
	DealStageProspect    DealStage = "prospect"
	DealStageSurvey      DealStage = "survey"
	DealStageNegotiation DealStage = "negotiation"
	DealStageClosing     DealStage = "closing"
	DealStageClosedWon   DealStage = "closed_won"
	DealStageClosedLost  DealStage = "closed_lost"
)

type DealStatus string

const (
	DealStatusOpen DealStatus = "open"
	DealStatusWon  DealStatus = "won"
	DealStatusLost DealStatus = "lost"
)

// Deal acts as a sales pipeline record mapped to a specific Customer
type Deal struct {
	ID            uuid.UUID       `json:"id"`
	Title         string          `json:"title"`
	CustomerID    uuid.UUID       `json:"customer_id"`
	ContactID     *uuid.UUID      `json:"contact_id,omitempty"`
	AssignedTo    *uuid.UUID      `json:"sales_id,omitempty"`
	Stage         DealStage       `json:"stage"`
	Status        DealStatus      `json:"status"`
	Amount        *float64        `json:"amount,omitempty"`
	Probability   int16           `json:"probability"` // 0-100 percentage
	ExpectedClose *utils.FlexTime  `json:"expected_close,omitempty"`
	ClosedAt      *utils.FlexTime  `json:"closed_at,omitempty"`
	LostReason    *string         `json:"lost_reason,omitempty"`
	Description   *string         `json:"description,omitempty"`
	Items         []DealItem      `json:"items,omitempty"`
	CreatedBy     *uuid.UUID      `json:"created_by,omitempty"`
	Customer      *Customer       `json:"customer,omitempty"`
	CreatedAt     utils.FlexTime   `json:"created_at"`
	UpdatedAt     utils.FlexTime   `json:"updated_at"`
}

// DealStageHistory logs every drag-and-drop / Kanban transition for analytical funnels
type DealStageHistory struct {
	ID        int64           `json:"id"`
	DealID    uuid.UUID       `json:"deal_id"`
	FromStage *DealStage      `json:"from_stage,omitempty"`
	ToStage   DealStage       `json:"to_stage"`
	ChangedBy *uuid.UUID      `json:"changed_by,omitempty"`
	Notes     *string         `json:"notes,omitempty"`
	ChangedAt utils.FlexTime   `json:"changed_at"`
}
