package usecase

import (
	"context"
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"
	"fmt"
	"github.com/google/uuid"
)

type StockTransferUseCase interface {
	RequestTransfer(ctx context.Context, transfer *models.StockTransfer) (*models.StockTransfer, error)
	GetTransfer(ctx context.Context, id uuid.UUID) (*models.StockTransfer, error)
	ListTransfers(ctx context.Context, filter repository.StockTransferFilter) ([]*models.StockTransfer, error)
	ApproveTransfer(ctx context.Context, id uuid.UUID) error
	RejectTransfer(ctx context.Context, id uuid.UUID, reason string) error
}

type stockTransferUseCaseImpl struct {
	repo         repository.StockTransferRepository
	vanStockRepo repository.VanStockRepository
}

func NewStockTransferUseCase(repo repository.StockTransferRepository, vanStockRepo repository.VanStockRepository) StockTransferUseCase {
	return &stockTransferUseCaseImpl{
		repo:         repo,
		vanStockRepo: vanStockRepo,
	}
}

func (u *stockTransferUseCaseImpl) RequestTransfer(ctx context.Context, st *models.StockTransfer) (*models.StockTransfer, error) {
	st.Status = models.StockTransferStatusPending
	if err := u.repo.Create(ctx, st); err != nil {
		return nil, err
	}
	return st, nil
}

func (u *stockTransferUseCaseImpl) GetTransfer(ctx context.Context, id uuid.UUID) (*models.StockTransfer, error) {
	return u.repo.GetByID(ctx, id)
}

func (u *stockTransferUseCaseImpl) ListTransfers(ctx context.Context, filter repository.StockTransferFilter) ([]*models.StockTransfer, error) {
	return u.repo.List(ctx, filter)
}

func (u *stockTransferUseCaseImpl) ApproveTransfer(ctx context.Context, id uuid.UUID) error {
	st, err := u.repo.GetByID(ctx, id)
	if err != nil {
		return err
	}
	if st == nil {
		return fmt.Errorf("transfer not found")
	}
	if st.Status != models.StockTransferStatusPending {
		return fmt.Errorf("transfer is already %s", st.Status)
	}

	// Logic to update van_stock
	for _, item := range st.Items {
		vs, err := u.vanStockRepo.GetByUserAndProduct(ctx, st.SalesID, item.ProductID)
		if err != nil {
			return err
		}

		if st.Type == models.StockTransferTypeLoading {
			if vs == nil {
				// Create new van stock record
				newVs := &models.VanStock{
					UserID:    st.SalesID,
					ProductID: item.ProductID,
					Quantity:  item.Quantity,
				}
				if err := u.vanStockRepo.Create(ctx, newVs); err != nil {
					return err
				}
			} else {
				// Update existing
				vs.Quantity += item.Quantity
				if err := u.vanStockRepo.Update(ctx, vs); err != nil {
					return err
				}
			}
		} else if st.Type == models.StockTransferTypeUnloading {
			if vs == nil || vs.Quantity < item.Quantity {
				return fmt.Errorf("insufficient van stock for product %s", item.ProductID)
			}
			vs.Quantity -= item.Quantity
			if err := u.vanStockRepo.Update(ctx, vs); err != nil {
				return err
			}
		}
	}

	return u.repo.UpdateStatus(ctx, id, models.StockTransferStatusConfirmed)
}

func (u *stockTransferUseCaseImpl) RejectTransfer(ctx context.Context, id uuid.UUID, reason string) error {
	// Potentially store reason in notes
	return u.repo.UpdateStatus(ctx, id, models.StockTransferStatusRejected)
}
