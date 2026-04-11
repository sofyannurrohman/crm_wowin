package postgres

import (
	"context"
	"crm_wowin_backend/internal/domain/dberrors"
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"
	"errors"
	"fmt"
	"strings"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type salesActivityRepoImpl struct {
	db *pgxpool.Pool
}

func NewSalesActivityRepository(db *pgxpool.Pool) repository.SalesActivityRepository {
	return &salesActivityRepoImpl{db: db}
}

func (r *salesActivityRepoImpl) Create(ctx context.Context, a *models.SalesActivity) error {
	query := `INSERT INTO sales_activities (
				user_id, lead_id, customer_id, deal_id, task_destination_id,
				type, title, notes, latitude, longitude,
				check_in_time, check_out_time, selfie_photo_path, place_photo_path, address, outcome, activity_at, distance, is_offline
			  ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19)
			  RETURNING id, created_at, updated_at`

	err := r.db.QueryRow(ctx, query,
		a.UserID, a.LeadID, a.CustomerID, a.DealID, a.TaskDestinationID,
		a.Type, a.Title, a.Notes, a.Latitude, a.Longitude,
		a.CheckInTime, a.CheckOutTime, a.SelfiePhotoPath, a.PlacePhotoPath, a.Address, a.Outcome, a.ActivityAt, a.Distance, a.IsOffline,
	).Scan(&a.ID, &a.CreatedAt, &a.UpdatedAt)
	return err
}

func (r *salesActivityRepoImpl) GetByID(ctx context.Context, id uuid.UUID) (*models.SalesActivity, error) {
	query := `SELECT id, user_id, lead_id, customer_id, deal_id, task_destination_id, type, title, notes, latitude, longitude, 
				check_in_time, check_out_time, selfie_photo_path, place_photo_path, address, outcome, activity_at, created_at, updated_at, distance, is_offline
			  FROM sales_activities WHERE id = $1`

	var a models.SalesActivity
	err := r.db.QueryRow(ctx, query, id).Scan(
		&a.ID, &a.UserID, &a.LeadID, &a.CustomerID, &a.DealID, &a.TaskDestinationID,
		&a.Type, &a.Title, &a.Notes, &a.Latitude, &a.Longitude,
		&a.CheckInTime, &a.CheckOutTime, &a.SelfiePhotoPath, &a.PlacePhotoPath, &a.Address, &a.Outcome,
		&a.ActivityAt, &a.CreatedAt, &a.UpdatedAt, &a.Distance, &a.IsOffline,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, dberrors.ErrNotFound
	}
	return &a, err
}

func (r *salesActivityRepoImpl) List(ctx context.Context, filter repository.SalesActivityFilter) ([]*models.SalesActivity, error) {
	var where []string
	var args []interface{}
	argPos := 1

	if filter.SalesID != nil {
		where = append(where, fmt.Sprintf("user_id = $%d", argPos))
		args = append(args, *filter.SalesID)
		argPos++
	}
	if filter.LeadID != nil {
		where = append(where, fmt.Sprintf("lead_id = $%d", argPos))
		args = append(args, *filter.LeadID)
		argPos++
	}
	if filter.CustomerID != nil {
		where = append(where, fmt.Sprintf("customer_id = $%d", argPos))
		args = append(args, *filter.CustomerID)
		argPos++
	}
	if filter.DealID != nil {
		where = append(where, fmt.Sprintf("deal_id = $%d", argPos))
		args = append(args, *filter.DealID)
		argPos++
	}
	if filter.StartDate != nil {
		where = append(where, fmt.Sprintf("activity_at >= $%d", argPos))
		args = append(args, *filter.StartDate)
		argPos++
	}
	if filter.EndDate != nil {
		where = append(where, fmt.Sprintf("activity_at <= $%d", argPos))
		args = append(args, *filter.EndDate)
		argPos++
	}

	query := `SELECT sa.id, sa.user_id, sa.lead_id, sa.customer_id, sa.deal_id, sa.task_destination_id, sa.type, sa.title, sa.notes, sa.latitude, sa.longitude, 
	            sa.check_in_time, sa.check_out_time, sa.selfie_photo_path, sa.place_photo_path, sa.address, sa.outcome, sa.activity_at, sa.created_at, sa.updated_at, sa.distance, sa.is_offline,
				d.title as deal_title
			  FROM sales_activities sa
			  LEFT JOIN deals d ON sa.deal_id = d.id`
	if len(where) > 0 {
		w := strings.Join(where, " AND ")
		w = strings.ReplaceAll(w, "user_id", "sa.user_id")
		w = strings.ReplaceAll(w, "lead_id", "sa.lead_id") // also ambiguity fixes
		w = strings.ReplaceAll(w, "customer_id", "sa.customer_id")
		w = strings.ReplaceAll(w, "activity_at", "sa.activity_at")
		query += " WHERE " + w
	}
	query += " ORDER BY sa.activity_at DESC"

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []*models.SalesActivity
	for rows.Next() {
		var a models.SalesActivity
		err := rows.Scan(
			&a.ID, &a.UserID, &a.LeadID, &a.CustomerID, &a.DealID, &a.TaskDestinationID,
			&a.Type, &a.Title, &a.Notes, &a.Latitude, &a.Longitude,
			&a.CheckInTime, &a.CheckOutTime, &a.SelfiePhotoPath, &a.PlacePhotoPath, &a.Address, &a.Outcome,
			&a.ActivityAt, &a.CreatedAt, &a.UpdatedAt, &a.Distance, &a.IsOffline,
			&a.DealTitle,
		)
		if err != nil {
			return nil, err
		}
		results = append(results, &a)
	}
	return results, nil
}

func (r *salesActivityRepoImpl) Update(ctx context.Context, a *models.SalesActivity) error {
	query := `UPDATE sales_activities SET 
				lead_id=$1, customer_id=$2, deal_id=$3, task_destination_id=$4, type=$5, 
				title=$6, notes=$7, latitude=$8, longitude=$9, 
				check_in_time=$10, check_out_time=$11, selfie_photo_path=$12, place_photo_path=$13, address=$14, outcome=$15,
				activity_at=$16, updated_at=NOW(), distance=$17, is_offline=$18
			  WHERE id=$19 RETURNING updated_at`

	err := r.db.QueryRow(ctx, query,
		a.LeadID, a.CustomerID, a.DealID, a.TaskDestinationID, a.Type,
		a.Title, a.Notes, a.Latitude, a.Longitude,
		a.CheckInTime, a.CheckOutTime, a.SelfiePhotoPath, a.PlacePhotoPath, a.Address, a.Outcome,
		a.ActivityAt, a.Distance, a.IsOffline, a.ID,
	).Scan(&a.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return dberrors.ErrNotFound
	}
	return err
}

func (r *salesActivityRepoImpl) Delete(ctx context.Context, id uuid.UUID) error {
	res, err := r.db.Exec(ctx, "DELETE FROM sales_activities WHERE id = $1", id)
	if err != nil {
		return err
	}
	if res.RowsAffected() == 0 {
		return dberrors.ErrNotFound
	}
	return nil
}
