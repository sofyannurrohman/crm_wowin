package models

import (
	"time"

	"github.com/google/uuid"
)

type TaskPriority string

const (
	TaskPriorityLow    TaskPriority = "LOW"
	TaskPriorityMedium TaskPriority = "MEDIUM"
	TaskPriorityHigh   TaskPriority = "HIGH"
)

type TaskStatus string

const (
	TaskStatusTodo       TaskStatus = "TODO"
	TaskStatusInProgress TaskStatus = "IN_PROGRESS"
	TaskStatusCompleted  TaskStatus = "COMPLETED"
	TaskStatusCancelled  TaskStatus = "CANCELLED"
)

type Task struct {
	ID           uuid.UUID         `json:"id"`
	SalesID      uuid.UUID         `json:"sales_id"`
	WarehouseID  uuid.UUID         `json:"warehouse_id"` // Mandatory as per user feedback
	Warehouse    *Warehouse        `json:"warehouse,omitempty"`
	Title        string            `json:"title"`
	Description  string            `json:"description"`
	Destinations []TaskDestination `json:"destinations,omitempty"`
	Priority     TaskPriority      `json:"priority"`
	Status       TaskStatus        `json:"status"`
	DueDate      *time.Time        `json:"due_date,omitempty"`
	CompletedAt  *time.Time        `json:"completed_at,omitempty"`
	CreatedAt    time.Time         `json:"created_at"`
	UpdatedAt    time.Time         `json:"updated_at"`
}
