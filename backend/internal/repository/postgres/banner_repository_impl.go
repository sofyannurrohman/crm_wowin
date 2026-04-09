package postgres

import (
	"context"
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"
	"errors"
	"fmt"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type bannerRepoImpl struct {
	db *pgxpool.Pool
}

func NewBannerRepository(db *pgxpool.Pool) repository.BannerRepository {
	return &bannerRepoImpl{db: db}
}

func (r *bannerRepoImpl) Create(ctx context.Context, b *models.Banner) error {
	query := `
		INSERT INTO banners (sales_id, customer_id, lead_id, shop_name, content, dimensions, photo_path, latitude, longitude, address)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
		RETURNING id, created_at, updated_at
	`
	err := r.db.QueryRow(ctx, query,
		b.SalesID, b.CustomerID, b.LeadID, b.ShopName, b.Content, b.Dimensions, b.PhotoPath, b.Latitude, b.Longitude, b.Address,
	).Scan(&b.ID, &b.CreatedAt, &b.UpdatedAt)

	return err
}

func (r *bannerRepoImpl) GetByID(ctx context.Context, id uuid.UUID) (*models.Banner, error) {
	query := `
		SELECT id, sales_id, customer_id, lead_id, shop_name, content, dimensions, photo_path, latitude, longitude, address, created_at, updated_at
		FROM banners
		WHERE id = $1
	`
	var b models.Banner
	err := r.db.QueryRow(ctx, query, id).Scan(
		&b.ID, &b.SalesID, &b.CustomerID, &b.LeadID, &b.ShopName, &b.Content, &b.Dimensions, &b.PhotoPath, &b.Latitude, &b.Longitude, &b.Address, &b.CreatedAt, &b.UpdatedAt,
	)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}
	return &b, nil
}

func (r *bannerRepoImpl) List(ctx context.Context, filter repository.BannerFilter) ([]*models.Banner, error) {
	query := `
		SELECT id, sales_id, customer_id, lead_id, shop_name, content, dimensions, photo_path, latitude, longitude, address, created_at, updated_at
		FROM banners
		WHERE 1=1
	`
	args := []interface{}{}
	argIdx := 1

	if filter.SalesID != nil {
		query += fmt.Sprintf(" AND sales_id = $%d", argIdx)
		args = append(args, *filter.SalesID)
		argIdx++
	}
	if filter.CustomerID != nil {
		query += fmt.Sprintf(" AND customer_id = $%d", argIdx)
		args = append(args, *filter.CustomerID)
		argIdx++
	}
	if filter.LeadID != nil {
		query += fmt.Sprintf(" AND lead_id = $%d", argIdx)
		args = append(args, *filter.LeadID)
		argIdx++
	}

	query += " ORDER BY created_at DESC"

	if filter.Limit > 0 {
		query += fmt.Sprintf(" LIMIT $%d", argIdx)
		args = append(args, filter.Limit)
		argIdx++
	}
	if filter.Offset > 0 {
		query += fmt.Sprintf(" OFFSET $%d", argIdx)
		args = append(args, filter.Offset)
		argIdx++
	}

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var banners []*models.Banner
	for rows.Next() {
		var b models.Banner
		err := rows.Scan(
			&b.ID, &b.SalesID, &b.CustomerID, &b.LeadID, &b.ShopName, &b.Content, &b.Dimensions, &b.PhotoPath, &b.Latitude, &b.Longitude, &b.Address, &b.CreatedAt, &b.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		banners = append(banners, &b)
	}

	return banners, nil
}
