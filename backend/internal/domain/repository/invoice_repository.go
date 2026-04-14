package repository

import (
	"context"
	"crm_wowin_backend/internal/domain/models"
	"github.com/google/uuid"
)

type InvoiceFilter struct {
	CustomerID *uuid.UUID
	Status     *models.InvoiceStatus
}

type InvoiceRepository interface {
	Create(ctx context.Context, invoice *models.Invoice) error
	GetByID(ctx context.Context, id uuid.UUID) (*models.Invoice, error)
	List(ctx context.Context, filter InvoiceFilter) ([]*models.Invoice, error)
	GetByCustomerID(ctx context.Context, customerID uuid.UUID) ([]*models.Invoice, error)
	UpdateStatus(ctx context.Context, id uuid.UUID, status models.InvoiceStatus) error
	Update(ctx context.Context, invoice *models.Invoice) error
}
