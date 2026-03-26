package repository

import (
	"context"
	"crm_wowin_backend/internal/domain/models"

	"github.com/google/uuid"
)

type CustomerFilter struct {
	Search      string
	Status      string
	Type        string
	AssignedTo  *uuid.UUID
	TerritoryID *uuid.UUID
	Limit       int
	Offset      int
}

// CustomerRepository defines the persistence interface for Customers
type CustomerRepository interface {
	Create(ctx context.Context, customer *models.Customer) error
	GetByID(ctx context.Context, id uuid.UUID) (*models.Customer, error)
	List(ctx context.Context, filter CustomerFilter) ([]*models.Customer, int, error) // Returns items and total count
	Update(ctx context.Context, customer *models.Customer) error
	Delete(ctx context.Context, id uuid.UUID) error
	
	// Coordinates update explicitly
	UpdateLocation(ctx context.Context, id uuid.UUID, lat, lon float64) error
	
	// Contacts
	AddContact(ctx context.Context, contact *models.Contact) error
	GetContactsByCustomer(ctx context.Context, customerID uuid.UUID) ([]*models.Contact, error)
}
