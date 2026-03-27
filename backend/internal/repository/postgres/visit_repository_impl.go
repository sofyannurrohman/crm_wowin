package postgres

import (
	"context"
	"crm_wowin_backend/internal/domain/dberrors"
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"
	"errors"
	"fmt"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type visitRepoImpl struct {
	db *pgxpool.Pool
}

func NewVisitRepository(db *pgxpool.Pool) repository.VisitRepository {
	return &visitRepoImpl{db: db}
}

// === SCHEDULES ===

func (r *visitRepoImpl) CreateSchedule(ctx context.Context, s *models.VisitSchedule) error {
	query := `INSERT INTO visit_schedules (sales_id, customer_id, scheduled_date, notes)
			  VALUES ($1, $2, $3, $4) RETURNING id, created_at, updated_at`
	err := r.db.QueryRow(ctx, query, s.SalesID, s.CustomerID, s.Date, s.Notes).
		Scan(&s.ID, &s.CreatedAt, &s.UpdatedAt)
	return err
}

func (r *visitRepoImpl) GetScheduleByID(ctx context.Context, id uuid.UUID) (*models.VisitSchedule, error) {
	query := `SELECT id, sales_id, customer_id, scheduled_date, notes, created_at, updated_at
			  FROM visit_schedules WHERE id=$1`
	var s models.VisitSchedule
	err := r.db.QueryRow(ctx, query, id).Scan(
		&s.ID, &s.SalesID, &s.CustomerID, &s.Date, &s.Notes, &s.CreatedAt, &s.UpdatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, dberrors.ErrNotFound
	}
	return &s, err
}

func (r *visitRepoImpl) ListSchedules(ctx context.Context, filter repository.ScheduleFilter) ([]*models.VisitSchedule, error) {
	baseQuery := `SELECT id, sales_id, customer_id, scheduled_date, notes, created_at, updated_at 
				  FROM visit_schedules WHERE 1=1`

	args := []interface{}{}
	argCount := 1

	if filter.SalesID != nil {
		baseQuery += fmt.Sprintf(" AND sales_id = $%d", argCount)
		args = append(args, *filter.SalesID)
		argCount++
	}
	if filter.CustomerID != nil {
		baseQuery += fmt.Sprintf(" AND customer_id = $%d", argCount)
		args = append(args, *filter.CustomerID)
		argCount++
	}
	if filter.StartDate != nil {
		baseQuery += fmt.Sprintf(" AND scheduled_date >= $%d", argCount)
		args = append(args, *filter.StartDate)
		argCount++
	}
	if filter.EndDate != nil {
		baseQuery += fmt.Sprintf(" AND scheduled_date <= $%d", argCount)
		args = append(args, *filter.EndDate)
		argCount++
	}

	baseQuery += " ORDER BY scheduled_date ASC, created_at ASC"

	rows, err := r.db.Query(ctx, baseQuery, args...)
	if err != nil {
		fmt.Printf("❌ Database query error (ListSchedules): %v\n", err)
		return nil, err
	}
	defer rows.Close()

	var results []*models.VisitSchedule
	for rows.Next() {
		var s models.VisitSchedule
		err := rows.Scan(&s.ID, &s.SalesID, &s.CustomerID, &s.Date, &s.Notes, &s.CreatedAt, &s.UpdatedAt)
		if err != nil {
			fmt.Printf("❌ Database scan error (ListSchedules): %v\n", err)
			return nil, err
		}
		results = append(results, &s)
	}

	return results, nil
}

func (r *visitRepoImpl) UpdateSchedule(ctx context.Context, s *models.VisitSchedule) error {
	query := `UPDATE visit_schedules SET 
				sales_id=$1, customer_id=$2, scheduled_date=$3, notes=$4, updated_at=NOW()
			  WHERE id=$5 RETURNING updated_at`
	err := r.db.QueryRow(ctx, query, s.SalesID, s.CustomerID, s.Date, s.Notes, s.ID).Scan(&s.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return dberrors.ErrNotFound
	}
	return err
}

func (r *visitRepoImpl) DeleteSchedule(ctx context.Context, id uuid.UUID) error {
	res, err := r.db.Exec(ctx, "DELETE FROM visit_schedules WHERE id=$1", id)
	if err != nil {
		return err
	}
	if res.RowsAffected() == 0 {
		return dberrors.ErrNotFound
	}
	return nil
}

// === EXECUTION FOOTPRINTS (Activities) ===

func (r *visitRepoImpl) LogActivity(ctx context.Context, a *models.VisitActivity) error {
	// Notice that the distance formula will automatically be generated via postgis geometry if not offline 
	// To keep it simple, we store geometry points implicitly into location via MakePoint.
	// We allow passing of pre-calculated 'distance' param if computed by mobile or Go Usecase.

	query := `INSERT INTO visit_activities (
				schedule_id, sales_id, customer_id, type, 
				location, photo_path, distance, is_offline, notes
			  ) VALUES (
				$1, $2, $3, $4, 
				ST_SetSRID(ST_MakePoint($5, $6), 4326), $7, $8, $9, $10
			  ) RETURNING id, created_at`
	
	err := r.db.QueryRow(ctx, query, 
		a.ScheduleID, a.SalesID, a.CustomerID, a.Type,
		a.Longitude, a.Latitude, a.PhotoPath, a.Distance, a.IsOffline, a.Notes,
	).Scan(&a.ID, &a.CreatedAt)

	return err
}

func (r *visitRepoImpl) GetActivitiesBySchedule(ctx context.Context, scheduleID uuid.UUID) ([]*models.VisitActivity, error) {
	query := `
		SELECT 	id, schedule_id, sales_id, customer_id, type, 
				ST_Y(location::geometry) as lat, ST_X(location::geometry) as lon, 
				photo_path, distance, is_offline, notes, created_at
		FROM visit_activities WHERE schedule_id=$1 ORDER BY created_at ASC
	`
	rows, err := r.db.Query(ctx, query, scheduleID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return scanActivities(rows)
}

func (r *visitRepoImpl) GetActivitiesByCustomer(ctx context.Context, customerID uuid.UUID) ([]*models.VisitActivity, error) {
	query := `
		SELECT 	id, schedule_id, sales_id, customer_id, type, 
				ST_Y(location::geometry) as lat, ST_X(location::geometry) as lon, 
				photo_path, distance, is_offline, notes, created_at
		FROM visit_activities WHERE customer_id=$1 ORDER BY created_at DESC
	`
	rows, err := r.db.Query(ctx, query, customerID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return scanActivities(rows)
}

func scanActivities(rows pgx.Rows) ([]*models.VisitActivity, error) {
	var results []*models.VisitActivity
	for rows.Next() {
		var a models.VisitActivity
		err := rows.Scan(
			&a.ID, &a.ScheduleID, &a.SalesID, &a.CustomerID, &a.Type,
			&a.Latitude, &a.Longitude, &a.PhotoPath, &a.Distance, &a.IsOffline, &a.Notes, &a.CreatedAt,
		)
		if err != nil {
			return nil, err
		}
		results = append(results, &a)
	}
	return results, nil
}
