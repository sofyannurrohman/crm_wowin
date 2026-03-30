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
	ID           uuid.UUID    `json:"id"`
	SalesID      uuid.UUID    `json:"sales_id"`
	CustomerID   *uuid.UUID   `json:"customer_id,omitempty"`
	CustomerName string       `json:"customer_name,omitempty"` // From join
	Title        string       `json:"title"`
	Description  string       `json:"description"`
	Priority     TaskPriority `json:"priority"`
	Status       TaskStatus   `json:"status"`
	DueDate      *time.Time   `json:"due_date,omitempty"`
	CompletedAt  *time.Time   `json:"completed_at,omitempty"`
	CreatedAt    time.Time    `json:"created_at"`
	UpdatedAt    time.Time    `json:"updated_at"`
}
