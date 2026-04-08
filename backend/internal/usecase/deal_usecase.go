package usecase

import (
	"context"
	"crm_wowin_backend/internal/domain/dberrors"
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"
	"crm_wowin_backend/pkg/utils"
	"time"

	"github.com/google/uuid"
)

// DealUseCase handles Pipeline processes
type DealUseCase interface {
	CreateDeal(ctx context.Context, d *models.Deal, creatorID uuid.UUID) (*models.Deal, error)
	GetDealDetails(ctx context.Context, id uuid.UUID) (*models.Deal, []*models.DealStageHistory, *models.Customer, error)
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
		d.Stage = models.DealStageProspect
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

func (u *dealUseCaseImpl) GetDealDetails(ctx context.Context, id uuid.UUID) (*models.Deal, []*models.DealStageHistory, *models.Customer, error) {
	deal, err := u.dealRepo.GetByID(ctx, id)
	if err != nil {
		return nil, nil, nil, err
	}

	history, err := u.dealRepo.GetStageHistory(ctx, deal.ID)
	if err != nil {
		history = make([]*models.DealStageHistory, 0)
	}

	customer, _ := u.custRepo.GetByID(ctx, deal.CustomerID)

	return deal, history, customer, nil
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
		d.ClosedAt = utils.ToFlexTimePtr(time.Now())
	}

	err = u.dealRepo.Update(ctx, d)
	if err != nil {
		return nil, err
	}
	return d, nil
}

func (u *dealUseCaseImpl) ChangeDealStage(ctx context.Context, dealID uuid.UUID, newStage models.DealStage, changedBy uuid.UUID, notes *string) error {
	existing, err := u.dealRepo.GetByID(ctx, dealID)
	if err != nil {
		return err
	}

	// Terminal stage detection for "Sales Performance" (Status updates)
	if newStage == models.DealStageClosedWon || newStage == models.DealStageClosedLost {
		existing.Stage = newStage
		if newStage == models.DealStageClosedWon {
			existing.Status = models.DealStatusWon
		} else {
			existing.Status = models.DealStatusLost
		}
		existing.ClosedAt = utils.ToFlexTimePtr(time.Now())
		
		// Update the whole record to capture Status and ClosedAt
		return u.dealRepo.Update(ctx, existing)
	}

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
	existing, err := u.leadRepo.GetByID(ctx, l.ID)
	if err != nil {
		return nil, err
	}

	// PATCH/Partial Update Support: Only overwrite if fields are provided/non-zero
	if l.Title != "" {
		existing.Title = l.Title
	}
	if l.Name != "" {
		existing.Name = l.Name
	}
	if l.Company != nil {
		existing.Company = l.Company
	}
	if l.Email != nil {
		existing.Email = l.Email
	}
	if l.Phone != nil {
		existing.Phone = l.Phone
	}
	if l.Source != "" {
		existing.Source = l.Source
	}
	if l.Status != "" {
		existing.Status = l.Status
	}
	if l.AssignedTo != nil {
		existing.AssignedTo = l.AssignedTo
	}
	if l.EstimatedValue != nil {
		existing.EstimatedValue = l.EstimatedValue
	}
	if len(l.PotentialProducts) > 0 {
		existing.PotentialProducts = l.PotentialProducts
	}
	if l.Notes != nil {
		existing.Notes = l.Notes
	}
	if l.Latitude != nil {
		existing.Latitude = l.Latitude
	}
	if l.Longitude != nil {
		existing.Longitude = l.Longitude
	}

	err = u.leadRepo.Update(ctx, existing)
	return existing, err
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

	// Map lead.Company text to CustomerType
	customerType := models.TypeCompany
	if lead.Company != nil {
		switch *lead.Company {
		case "Warung Makan":
			customerType = models.TypeWarung
		case "Toko Kelontong":
			customerType = models.TypeToko
		case "Retail / Minimarket":
			customerType = models.TypeRetail
		case "Agen / Distributor":
			customerType = models.TypeAgen
		case "Restoran":
			customerType = models.TypeRestoran
		case "Cafe":
			customerType = models.TypeCafe
		case "Lainnya":
			customerType = models.TypeLainnya
		}
	}

	// Morphing entity
	customer := &models.Customer{
		Type:        customerType,
		Name:        customerName,
		CompanyName: lead.Company,
		Email:       lead.Email,
		Phone:       lead.Phone,
		Status:      models.CustomerStatusActive,
		AssignedTo:  lead.AssignedTo, // inherits assignment
		CreatedBy:   &operatorID,
		Latitude:    lead.Latitude,
		Longitude:   lead.Longitude,
	}

	// We create the Customer via its own domain
	err = u.custRepo.Create(ctx, customer)
	if err != nil {
		return nil, err
	}

	// Mark Lead as converted safely
	lead.Status = models.LeadStatusQualified
	lead.CustomerID = &customer.ID
	lead.ConvertedAt = utils.ToFlexTimePtr(time.Now())
	
	_ = u.leadRepo.Update(ctx, lead)

	return customer, nil
}
