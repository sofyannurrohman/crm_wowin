package usecase

import (
	"context"
	"crm_wowin_backend/internal/domain/dberrors"
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"

	"github.com/google/uuid"
)

// ProductUseCase serves interactions surrounding product catalogs and deal attachments.
type ProductUseCase interface {
	// Categories
	CreateCategory(ctx context.Context, category *models.ProductCategory) (*models.ProductCategory, error)
	GetCategory(ctx context.Context, id uuid.UUID) (*models.ProductCategory, error)
	ListCategories(ctx context.Context) ([]*models.ProductCategory, error)
	UpdateCategory(ctx context.Context, category *models.ProductCategory) (*models.ProductCategory, error)

	// Products
	CreateProduct(ctx context.Context, product *models.Product) (*models.Product, error)
	GetProduct(ctx context.Context, id uuid.UUID) (*models.Product, error)
	ListProducts(ctx context.Context, filter repository.ProductFilter) ([]*models.Product, error)
	UpdateProduct(ctx context.Context, product *models.Product) (*models.Product, error)
	DeleteProduct(ctx context.Context, id uuid.UUID) error

	// Deal Items
	AddDealItem(ctx context.Context, item *models.DealItem) (*models.DealItem, error)
	ListDealItems(ctx context.Context, dealID uuid.UUID) ([]*models.DealItem, error)
	UpdateDealItem(ctx context.Context, item *models.DealItem) (*models.DealItem, error)
	RemoveDealItem(ctx context.Context, id uuid.UUID) error
}

type productUseCaseImpl struct {
	productRepo repository.ProductRepository
	itemRepo    repository.DealItemRepository
	dealRepo    repository.DealRepository
}

func NewProductUseCase(pr repository.ProductRepository, ir repository.DealItemRepository, dr repository.DealRepository) ProductUseCase {
	return &productUseCaseImpl{
		productRepo: pr,
		itemRepo:    ir,
		dealRepo:    dr,
	}
}

// === Categories ===

func (u *productUseCaseImpl) CreateCategory(ctx context.Context, c *models.ProductCategory) (*models.ProductCategory, error) {
	if err := u.productRepo.CreateCategory(ctx, c); err != nil {
		return nil, err
	}
	return c, nil
}

func (u *productUseCaseImpl) GetCategory(ctx context.Context, id uuid.UUID) (*models.ProductCategory, error) {
	return u.productRepo.GetCategoryByID(ctx, id)
}

func (u *productUseCaseImpl) ListCategories(ctx context.Context) ([]*models.ProductCategory, error) {
	return u.productRepo.ListCategories(ctx)
}

func (u *productUseCaseImpl) UpdateCategory(ctx context.Context, c *models.ProductCategory) (*models.ProductCategory, error) {
	_, err := u.productRepo.GetCategoryByID(ctx, c.ID)
	if err != nil {
		return nil, err
	}
	if err := u.productRepo.UpdateCategory(ctx, c); err != nil {
		return nil, err
	}
	return c, nil
}

// === Products ===

func (u *productUseCaseImpl) CreateProduct(ctx context.Context, p *models.Product) (*models.Product, error) {
	if p.CategoryID != nil {
		_, err := u.productRepo.GetCategoryByID(ctx, *p.CategoryID)
		if err != nil {
			return nil, dberrors.ErrInvalidInput // Target Category does not exist
		}
	}
	if err := u.productRepo.Create(ctx, p); err != nil {
		return nil, err
	}
	return p, nil
}

func (u *productUseCaseImpl) GetProduct(ctx context.Context, id uuid.UUID) (*models.Product, error) {
	return u.productRepo.GetByID(ctx, id)
}

func (u *productUseCaseImpl) ListProducts(ctx context.Context, filter repository.ProductFilter) ([]*models.Product, error) {
	return u.productRepo.List(ctx, filter)
}

func (u *productUseCaseImpl) UpdateProduct(ctx context.Context, p *models.Product) (*models.Product, error) {
	_, err := u.productRepo.GetByID(ctx, p.ID)
	if err != nil {
		return nil, err
	}
	if err := u.productRepo.Update(ctx, p); err != nil {
		return nil, err
	}
	return p, nil
}

func (u *productUseCaseImpl) DeleteProduct(ctx context.Context, id uuid.UUID) error {
	return u.productRepo.Delete(ctx, id)
}


// === Deal Items ===
func (u *productUseCaseImpl) AddDealItem(ctx context.Context, item *models.DealItem) (*models.DealItem, error) {
	// Verification checks
	if item.DealID != nil {
		_, err := u.dealRepo.GetByID(ctx, *item.DealID)
		if err != nil {
			return nil, dberrors.ErrInvalidInput // Parent deal must exist
		}
	}
	
	product, err := u.productRepo.GetByID(ctx, item.ProductID)
	if err != nil {
		return nil, dberrors.ErrInvalidInput // Product must exist
	}
	
	if item.Quantity <= 0 {
		item.Quantity = 1 // Enforce minimal quantity rules
	}
	
	// Inherit product price if unset dynamically
	if item.UnitPrice == 0 {
		item.UnitPrice = product.Price
	}

	if err := u.itemRepo.AddItem(ctx, item); err != nil {
		return nil, err
	}

	return item, nil
}

func (u *productUseCaseImpl) ListDealItems(ctx context.Context, dealID uuid.UUID) ([]*models.DealItem, error) {
	return u.itemRepo.GetItemsByDealID(ctx, dealID)
}

func (u *productUseCaseImpl) UpdateDealItem(ctx context.Context, item *models.DealItem) (*models.DealItem, error) {
	existing, err := u.itemRepo.GetItemByID(ctx, item.ID)
	if err != nil {
		return nil, err
	}
	
	// Ensure these primary pointers can't be hijacked during the update
	item.DealID = existing.DealID
	item.ProductID = existing.ProductID
	
	if item.Quantity <= 0 {
		item.Quantity = existing.Quantity
	}
	
	if err := u.itemRepo.UpdateItem(ctx, item); err != nil {
		return nil, err
	}

	return item, nil
}

func (u *productUseCaseImpl) RemoveDealItem(ctx context.Context, id uuid.UUID) error {
	return u.itemRepo.RemoveItem(ctx, id)
}
