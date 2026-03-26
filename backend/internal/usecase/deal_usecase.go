package usecase

import (
	"context"
	"crm_wowin_backend/internal/domain/dberrors"
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"
	"time"

	"github.com/google/uuid"
)

// DealUseCase handles Pipeline processes
type DealUseCase interface {
	CreateDeal(ctx context.Context, d *models.Deal, creatorID uuid.UUID) (*models.Deal, error)
	GetDealDetails(ctx context.Context, id uuid.UUID) (*models.Deal, []*models.DealStageHistory, error)
	ListDeals(ctx context.Context, filter repository.DealFilter) ([]*models.Deal, error)
	UpdateDeal(ctx context.Context, d *models.Deal) (*models.Deal, error)
	ChangeDealStage(ctx context.Context, dealID uuid.UUID, newStage models.DealStage, changedBy uuid.UUID, notes *string) error
}

type dealUseCaseImpl struct {
	dealRepo repository.DealRepository
	custRepo repository.CustomerRepository
}

func NewDealUseCase(dr repository.DealRepository, cr repository.CustomerRepository) DealUseCase {
	return &dealUseCaseImpl{dealRepo: dr, custRepo: cr}
}

func (u *dealUseCaseImpl) CreateDeal(ctx context.Context, d *models.Deal, creatorID uuid.UUID) (*models.Deal, error) {
	// Pre-ensure Customer exists
	_, err := u.custRepo.GetByID(ctx, d.CustomerID)
	if err != nil {
		return nil, dberrors.ErrInvalidInput // Can't start a deal without a valid client
	}

	d.CreatedBy = &creatorID
	
	if d.Stage == "" {
		d.Stage = models.DealStageProspecting
	}
	if d.Status == "" {
		d.Status = models.DealStatusOpen
	}

	err = u.dealRepo.Create(ctx, d)
	if err != nil {
		return nil, err
	}
	return d, nil
}

func (u *dealUseCaseImpl) GetDealDetails(ctx context.Context, id uuid.UUID) (*models.Deal, []*models.DealStageHistory, error) {
	deal, err := u.dealRepo.GetByID(ctx, id)
	if err != nil {
		return nil, nil, err
	}

	history, err := u.dealRepo.GetStageHistory(ctx, deal.ID)
	if err != nil {
		// Log omission, non-blocking
		history = make([]*models.DealStageHistory, 0)
	}

	return deal, history, nil
}

func (u *dealUseCaseImpl) ListDeals(ctx context.Context, filter repository.DealFilter) ([]*models.Deal, error) {
	return u.dealRepo.List(ctx, filter)
}

func (u *dealUseCaseImpl) UpdateDeal(ctx context.Context, d *models.Deal) (*models.Deal, error) {
	existing, err := u.dealRepo.GetByID(ctx, d.ID)
	if err != nil {
		return nil, err
	}

	// Auto compute close states if switched directly bypassing board 
	if d.Status != models.DealStatusOpen && existing.Status == models.DealStatusOpen {
		now := time.Now()
		d.ClosedAt = &now
	}

	err = u.dealRepo.Update(ctx, d)
	if err != nil {
		return nil, err
	}
	return d, nil
}

func (u *dealUseCaseImpl) ChangeDealStage(ctx context.Context, dealID uuid.UUID, newStage models.DealStage, changedBy uuid.UUID, notes *string) error {
	// Optional validation logic: 
	// Make sure deal isn't already Closed? We omit that strictness for flexibility here.
	return u.dealRepo.UpdateStage(ctx, dealID, newStage, &changedBy, notes)
}


// ==============
// LEAD USECASE
// ==============

type LeadUseCase interface {
	CreateLead(ctx context.Context, l *models.Lead, reqUser uuid.UUID) (*models.Lead, error)
	GetLead(ctx context.Context, id uuid.UUID) (*models.Lead, error)
	ListLeads(ctx context.Context, filter repository.LeadFilter) ([]*models.Lead, error)
	UpdateLead(ctx context.Context, l *models.Lead) (*models.Lead, error)
	DeleteLead(ctx context.Context, id uuid.UUID) error
	
	// Complex Business Flow
	ConvertLeadToCustomer(ctx context.Context, leadID uuid.UUID, operatorID uuid.UUID) (*models.Customer, error)
}

type leadUseCaseImpl struct {
	leadRepo repository.LeadRepository
	custRepo repository.CustomerRepository
}

func NewLeadUseCase(lr repository.LeadRepository, cr repository.CustomerRepository) LeadUseCase {
	return &leadUseCaseImpl{leadRepo: lr, custRepo: cr}
}

func (u *leadUseCaseImpl) CreateLead(ctx context.Context, l *models.Lead, reqUser uuid.UUID) (*models.Lead, error) {
	l.CreatedBy = &reqUser
	if l.Status == "" {
		l.Status = models.LeadStatusNew
	}
	if l.Source == "" {
		l.Source = models.LeadSourceOther
	}

	err := u.leadRepo.Create(ctx, l)
	return l, err
}

func (u *leadUseCaseImpl) GetLead(ctx context.Context, id uuid.UUID) (*models.Lead, error) {
	return u.leadRepo.GetByID(ctx, id)
}

func (u *leadUseCaseImpl) ListLeads(ctx context.Context, filter repository.LeadFilter) ([]*models.Lead, error) {
	return u.leadRepo.List(ctx, filter)
}

func (u *leadUseCaseImpl) UpdateLead(ctx context.Context, l *models.Lead) (*models.Lead, error) {
	_, err := u.leadRepo.GetByID(ctx, l.ID)
	if err != nil {
		return nil, err
	}
	err = u.leadRepo.Update(ctx, l)
	return l, err
}

func (u *leadUseCaseImpl) DeleteLead(ctx context.Context, id uuid.UUID) error {
	return u.leadRepo.Delete(ctx, id)
}

// ConvertLeadToCustomer migrates a lead into an actual client organically 
func (u *leadUseCaseImpl) ConvertLeadToCustomer(ctx context.Context, leadID uuid.UUID, operatorID uuid.UUID) (*models.Customer, error) {
	lead, err := u.leadRepo.GetByID(ctx, leadID)
	if err != nil {
		return nil, err
	}

	// Can't convert twice
	if lead.CustomerID != nil {
		return nil, dberrors.ErrConflict
	}

	customerName := lead.Name
	if lead.Company != nil && *lead.Company != "" {
		customerName = *lead.Company
	}

	// Morphing entity
	customer := &models.Customer{
		Type:        models.TypeCompany,
		Name:        customerName,
		CompanyName: lead.Company,
		Email:       lead.Email,
		Phone:       lead.Phone,
		Status:      models.CustomerStatusActive,
		AssignedTo:  lead.AssignedTo, // inherits assignment
		CreatedBy:   &operatorID,
	}

	// We create the Customer via its own domain
	err = u.custRepo.Create(ctx, customer)
	if err != nil {
		return nil, err
	}

	// Mark Lead as converted safely
	lead.Status = models.LeadStatusQualified
	lead.CustomerID = &customer.ID
	now := time.Now()
	lead.ConvertedAt = &now
	
	_ = u.leadRepo.Update(ctx, lead)

	return customer, nil
}
