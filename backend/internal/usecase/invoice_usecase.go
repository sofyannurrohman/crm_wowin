package usecase

import (
	"context"
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"
	"github.com/google/uuid"
)

type InvoiceUseCase interface {
	GetUnpaidInvoices(ctx context.Context, customerID uuid.UUID) ([]*models.Invoice, error)
	GetInvoice(ctx context.Context, id uuid.UUID) (*models.Invoice, error)
    CreateInvoice(ctx context.Context, invoice *models.Invoice) (*models.Invoice, error)
}

type invoiceUseCaseImpl struct {
	repo repository.InvoiceRepository
}

func NewInvoiceUseCase(repo repository.InvoiceRepository) InvoiceUseCase {
	return &invoiceUseCaseImpl{repo: repo}
}

func (u *invoiceUseCaseImpl) GetUnpaidInvoices(ctx context.Context, customerID uuid.UUID) ([]*models.Invoice, error) {
	status := models.InvoiceStatusUnpaid
	return u.repo.List(ctx, repository.InvoiceFilter{
		CustomerID: &customerID,
		Status:     &status,
	})
}

func (u *invoiceUseCaseImpl) GetInvoice(ctx context.Context, id uuid.UUID) (*models.Invoice, error) {
	return u.repo.GetByID(ctx, id)
}

func (u *invoiceUseCaseImpl) CreateInvoice(ctx context.Context, invoice *models.Invoice) (*models.Invoice, error) {
    if err := u.repo.Create(ctx, invoice); err != nil {
        return nil, err
    }
    return invoice, nil
}
