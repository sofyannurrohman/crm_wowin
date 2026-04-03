package models

import (
	"time"

	"github.com/google/uuid"
)

type DealStage string

const (
	DealStageProspecting  DealStage = "prospecting"
	DealStageQualification DealStage = "qualification"
	DealStageProposal     DealStage = "proposal"
	DealStageNegotiation  DealStage = "negotiation"
	DealStageClosedWon    DealStage = "closed_won"
	DealStageClosedLost   DealStage = "closed_lost"
)

type DealStatus string

const (
	DealStatusOpen DealStatus = "open"
	DealStatusWon  DealStatus = "won"
	DealStatusLost DealStatus = "lost"
)

// Deal acts as a sales pipeline record mapped to a specific Customer
type Deal struct {
	ID            uuid.UUID  `json:"id"`
	Title         string     `json:"title"`
	CustomerID    uuid.UUID  `json:"customer_id"`
	ContactID     *uuid.UUID `json:"contact_id,omitempty"`
	AssignedTo    *uuid.UUID `json:"assigned_to,omitempty"`
	Stage         DealStage  `json:"stage"`
	Status        DealStatus `json:"status"`
	Amount        *float64   `json:"amount,omitempty"`
	Probability   int16      `json:"probability"` // 0-100 percentage
	ExpectedClose *time.Time `json:"expected_close,omitempty"`
	ClosedAt      *time.Time `json:"closed_at,omitempty"`
	LostReason    *string    `json:"lost_reason,omitempty"`
	Description   *string    `json:"description,omitempty"`
	Items         []DealItem `json:"items,omitempty"`
	CreatedBy     *uuid.UUID `json:"created_by,omitempty"`
	CreatedAt     time.Time  `json:"created_at"`
	UpdatedAt     time.Time  `json:"updated_at"`
}

// DealStageHistory logs every drag-and-drop / Kanban transition for analytical funnels
type DealStageHistory struct {
	ID        int64      `json:"id"`
	DealID    uuid.UUID  `json:"deal_id"`
	FromStage *DealStage `json:"from_stage,omitempty"`
	ToStage   DealStage  `json:"to_stage"`
	ChangedBy *uuid.UUID `json:"changed_by,omitempty"`
	Notes     *string    `json:"notes,omitempty"`
	ChangedAt time.Time  `json:"changed_at"`
}
