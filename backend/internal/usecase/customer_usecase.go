package usecase

import (
	"context"
	"crm_wowin_backend/internal/domain/dberrors"
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"
	"time"

	"github.com/google/uuid"
)

// CustomerUseCase handles core logic for Customer CRUD and assignment
type CustomerUseCase interface {
	CreateCustomer(ctx context.Context, c *models.Customer, requestingUserID uuid.UUID) (*models.Customer, error)
	GetCustomerDetail(ctx context.Context, id uuid.UUID) (*models.Customer, []*models.Contact, error)
	ListCustomers(ctx context.Context, filter repository.CustomerFilter) ([]*models.Customer, int, error)
	UpdateCustomer(ctx context.Context, c *models.Customer) (*models.Customer, error)
	DeleteCustomer(ctx context.Context, id uuid.UUID) error
	
	// Contacts
	AddContact(ctx context.Context, contact *models.Contact) (*models.Contact, error)
}

type customerUseCaseImpl struct {
	repo repository.CustomerRepository
}

// NewCustomerUseCase wiring
func NewCustomerUseCase(r repository.CustomerRepository) CustomerUseCase {
	return &customerUseCaseImpl{repo: r}
}

func (u *customerUseCaseImpl) CreateCustomer(ctx context.Context, c *models.Customer, reqUser uuid.UUID) (*models.Customer, error) {
	// Auto stamp user trail
	c.CreatedBy = &reqUser
	
	if c.CheckinRadius == 0 {
		c.CheckinRadius = 100 // Set Default Policy Radius
	}
	
	if c.Status == "" {
		c.Status = models.CustomerStatusProspect
	}

	err := u.repo.Create(ctx, c)
	if err != nil {
		return nil, err
	}
	
	return c, nil
}

func (u *customerUseCaseImpl) GetCustomerDetail(ctx context.Context, id uuid.UUID) (*models.Customer, []*models.Contact, error) {
	customer, err := u.repo.GetByID(ctx, id)
	if err != nil {
		return nil, nil, err
	}

	contacts, err := u.repo.GetContactsByCustomer(ctx, id)
	if err != nil {
		// Non-blocking approach, logging omitted
		contacts = []*models.Contact{} 
	}

	return customer, contacts, nil
}

func (u *customerUseCaseImpl) ListCustomers(ctx context.Context, filter repository.CustomerFilter) ([]*models.Customer, int, error) {
	// sanitize and boundaries
	if filter.Limit <= 0 || filter.Limit > 100 {
		filter.Limit = 50
	}
	return u.repo.List(ctx, filter)
}

func (u *customerUseCaseImpl) UpdateCustomer(ctx context.Context, c *models.Customer) (*models.Customer, error) {
	// To perform safe update, ensure entity exists
	existing, err := u.repo.GetByID(ctx, c.ID)
	if err != nil {
		return nil, err
	}
	
	// Optional mapping - we blend values explicitly or replace fully based on API design. 
	// Assuming `c` contains the fully mutated struct from transport layer.
	c.CreatedAt = existing.CreatedAt // prevent created_at override
	
	err = u.repo.Update(ctx, c)
	if err != nil {
		return nil, err
	}

	return c, nil
}

func (u *customerUseCaseImpl) DeleteCustomer(ctx context.Context, id uuid.UUID) error {
	return u.repo.Delete(ctx, id)
}

func (u *customerUseCaseImpl) AddContact(ctx context.Context, contact *models.Contact) (*models.Contact, error) {
	// Fast-fail if customer not exist
	_, err := u.repo.GetByID(ctx, contact.CustomerID)
	if err != nil {
		return nil, dberrors.ErrInvalidInput
	}
	
	now := time.Now()
	contact.CreatedAt = now
	contact.UpdatedAt = now

	if err := u.repo.AddContact(ctx, contact); err != nil {
		return nil, err
	}

	return contact, nil
}
