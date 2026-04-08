package models

import (
	"crm_wowin_backend/pkg/utils"

	"github.com/google/uuid"
)

type TaskStatus string

const (
	TaskStatusTodo       TaskStatus = "pending"
	TaskStatusInProgress TaskStatus = "in_progress"
	TaskStatusCompleted  TaskStatus = "done"
	TaskStatusCancelled  TaskStatus = "cancelled"
)

type Task struct {
	ID           uuid.UUID         `json:"id"`
	SalesID      uuid.UUID         `json:"sales_id"`
	WarehouseID  uuid.UUID         `json:"warehouse_id"` // Mandatory as per user feedback
	Warehouse    *Warehouse        `json:"warehouse,omitempty"`
	Title        string            `json:"title"`
	Description  string            `json:"description"`
	Destinations []TaskDestination `json:"destinations,omitempty"`
	Status       TaskStatus        `json:"status"`
	DueDate      *utils.FlexTime   `json:"due_date,omitempty"`
	CompletedAt  *utils.FlexTime   `json:"completed_at,omitempty"`
	CreatedAt    utils.FlexTime    `json:"created_at"`
	UpdatedAt    utils.FlexTime    `json:"updated_at"`
}
