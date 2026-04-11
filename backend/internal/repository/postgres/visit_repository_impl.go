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
	query := `INSERT INTO visit_schedules (sales_id, lead_id, customer_id, deal_id, scheduled_date, notes)
			  VALUES ($1, $2, $3, $4, $5, $6) RETURNING id, created_at, updated_at`
	err := r.db.QueryRow(ctx, query, s.SalesID, s.LeadID, s.CustomerID, s.DealID, s.Date, s.Notes).
		Scan(&s.ID, &s.CreatedAt, &s.UpdatedAt)
	return err
}

func (r *visitRepoImpl) GetScheduleByID(ctx context.Context, id uuid.UUID) (*models.VisitSchedule, error) {
	query := `SELECT id, sales_id, lead_id, customer_id, deal_id, scheduled_date, notes, created_at, updated_at
			  FROM visit_schedules WHERE id=$1`
	var s models.VisitSchedule
	err := r.db.QueryRow(ctx, query, id).Scan(
		&s.ID, &s.SalesID, &s.LeadID, &s.CustomerID, &s.DealID, &s.Date, &s.Notes, &s.CreatedAt, &s.UpdatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, dberrors.ErrNotFound
	}
	return &s, err
}

func (r *visitRepoImpl) ListSchedules(ctx context.Context, filter repository.ScheduleFilter) ([]*models.VisitSchedule, error) {
	baseQuery := `SELECT id, sales_id, customer_id, deal_id, scheduled_date, notes, created_at, updated_at 
				  FROM visit_schedules WHERE 1=1`

	args := []interface{}{}
	argCount := 1

	if filter.SalesID != nil {
		baseQuery += fmt.Sprintf(" AND sales_id = $%d", argCount)
		args = append(args, *filter.SalesID)
		argCount++
	}
	if filter.LeadID != nil {
		baseQuery += fmt.Sprintf(" AND lead_id = $%d", argCount)
		args = append(args, *filter.LeadID)
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
		err := rows.Scan(&s.ID, &s.SalesID, &s.LeadID, &s.CustomerID, &s.DealID, &s.Date, &s.Notes, &s.CreatedAt, &s.UpdatedAt)
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
				sales_id=$1, lead_id=$2, customer_id=$3, deal_id=$4, scheduled_date=$5, notes=$6, updated_at=NOW()
			  WHERE id=$7 RETURNING updated_at`
	err := r.db.QueryRow(ctx, query, s.SalesID, s.LeadID, s.CustomerID, s.DealID, s.Date, s.Notes, s.ID).Scan(&s.UpdatedAt)
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
	// Map VisitActivity logic to 'visits' table
	// If it's a check-in, we INSERT. If check-out, we UPDATE.
	if a.Type == models.VisitTypeCheckIn {
		query := `INSERT INTO visits (
					schedule_id, task_destination_id, sales_id, lead_id, customer_id, deal_id, 
					checkin_at, checkin_location, checkin_distance, result_notes
				  ) VALUES (
					$1, $2, $3, $4, $5, $6, NOW(),
					ST_SetSRID(ST_MakePoint($7, $8), 4326), $9, $10
				  ) RETURNING id, created_at`
		
		err := r.db.QueryRow(ctx, query, 
			a.ScheduleID, a.TaskDestinationID, a.SalesID, a.LeadID, a.CustomerID, a.DealID,
			a.Longitude, a.Latitude, a.Distance, a.Notes,
		).Scan(&a.ID, &a.CreatedAt)
		return err
	} else {
		// Check-out logic
		query := `UPDATE visits SET 
					checkout_at = NOW(),
					checkout_location = ST_SetSRID(ST_MakePoint($1, $2), 4326),
					status = 'completed',
					result_notes = COALESCE(result_notes || '\n' || $3, $3)
				  WHERE (schedule_id = $4 OR task_destination_id = $5 OR (customer_id = $6 AND sales_id = $8) OR (lead_id = $7 AND sales_id = $8)) 
				  AND checkout_at IS NULL
				  RETURNING id, created_at`
		err := r.db.QueryRow(ctx, query, a.Longitude, a.Latitude, a.Notes, a.ScheduleID, a.TaskDestinationID, a.CustomerID, a.LeadID, a.SalesID).
			Scan(&a.ID, &a.CreatedAt)
		return err
	}
}

func (r *visitRepoImpl) GetActivitiesBySchedule(ctx context.Context, scheduleID uuid.UUID) ([]*models.VisitActivity, error) {
	query := `
		SELECT 	id, schedule_id, task_destination_id, sales_id, lead_id, customer_id, deal_id, 
				ST_Y(checkin_location::geometry) as lat, ST_X(checkin_location::geometry) as lon, 
				checkin_distance as distance, result_notes as notes, created_at,
				CASE WHEN checkout_at IS NULL THEN 'check-in' ELSE 'check-out' END as type,
				selfie_photo_path, place_photo_path
		FROM visits WHERE schedule_id=$1 ORDER BY created_at ASC
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
		SELECT 	id, schedule_id, task_destination_id, sales_id, lead_id, customer_id, deal_id, 
				ST_Y(checkin_location::geometry) as lat, ST_X(checkin_location::geometry) as lon, 
				checkin_distance as distance, result_notes as notes, created_at,
				CASE WHEN checkout_at IS NULL THEN 'check-in' ELSE 'check-out' END as type,
				selfie_photo_path, place_photo_path
		FROM visits WHERE customer_id=$1 ORDER BY created_at DESC
	`
	rows, err := r.db.Query(ctx, query, customerID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return scanActivities(rows)
}

func (r *visitRepoImpl) GetActivitiesByLead(ctx context.Context, leadID uuid.UUID) ([]*models.VisitActivity, error) {
	query := `
		SELECT 	id, schedule_id, task_destination_id, sales_id, lead_id, customer_id, deal_id, 
				ST_Y(checkin_location::geometry) as lat, ST_X(checkin_location::geometry) as lon, 
				checkin_distance as distance, result_notes as notes, created_at,
				CASE WHEN checkout_at IS NULL THEN 'check-in' ELSE 'check-out' END as type,
				selfie_photo_path, place_photo_path
		FROM visits WHERE lead_id=$1 ORDER BY created_at DESC
	`
	rows, err := r.db.Query(ctx, query, leadID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return scanActivities(rows)
}

func scanActivities(rows pgx.Rows) ([]*models.VisitActivity, error) {
	results := []*models.VisitActivity{}
	for rows.Next() {
		var a models.VisitActivity
		var selfie, place *string
		err := rows.Scan(
			&a.ID, &a.ScheduleID, &a.TaskDestinationID, &a.SalesID, &a.LeadID, &a.CustomerID, &a.DealID,
			&a.Latitude, &a.Longitude, 
			&a.Distance, &a.Notes, &a.CreatedAt, &a.Type,
			&selfie, &place,
		)
		if err != nil {
			return nil, err
		}
		if selfie != nil { a.SelfiePhotoPath = *selfie }
		if place != nil { a.PlacePhotoPath = *place }
		results = append(results, &a)
	}
	return results, nil
}

func (r *visitRepoImpl) ListActivities(ctx context.Context, filter repository.ActivityFilter) ([]*models.VisitActivity, error) {
	// Unified query for both Visits and Attendances
	baseQuery := `
		SELECT 	id, schedule_id, task_destination_id, sales_id, lead_id, customer_id, deal_id, 
				lat, lon, distance, notes, created_at, type, selfie_photo_path, place_photo_path
		FROM (
			-- Visit Activities
			SELECT 	id, schedule_id, task_destination_id, sales_id, lead_id, customer_id, deal_id, 
					ST_Y(checkin_location::geometry) as lat, ST_X(checkin_location::geometry) as lon, 
					checkin_distance as distance, result_notes as notes, created_at, 
					CASE 
						WHEN checkout_at IS NULL THEN 'check-in' 
						ELSE 'check-out' 
					END as type,
					selfie_photo_path, place_photo_path
			FROM visits
			WHERE 1=1
	`
	args := []interface{}{}
	argCount := 1

	if filter.SalesID != nil {
		baseQuery += fmt.Sprintf(" AND sales_id = $%d", argCount)
		args = append(args, *filter.SalesID)
		argCount++
	}
	if filter.LeadID != nil {
		baseQuery += fmt.Sprintf(" AND lead_id = $%d", argCount)
		args = append(args, *filter.LeadID)
		argCount++
	}
	if filter.CustomerID != nil {
		baseQuery += fmt.Sprintf(" AND customer_id = $%d", argCount)
		args = append(args, *filter.CustomerID)
		argCount++
	}
	if filter.StartDate != nil {
		baseQuery += fmt.Sprintf(" AND created_at >= $%d", argCount)
		args = append(args, *filter.StartDate)
		argCount++
	}
	if filter.EndDate != nil {
		baseQuery += fmt.Sprintf(" AND created_at <= $%d", argCount)
		args = append(args, *filter.EndDate)
		argCount++
	}

	// Add Attendance Union (only if CustomerID filter is not specified, as attendances aren't linked to customers)
	if filter.CustomerID == nil {
		baseQuery += `
			UNION ALL
			SELECT 	id, NULL as schedule_id, NULL as task_destination_id, user_id as sales_id, NULL as lead_id, '00000000-0000-0000-0000-000000000000'::uuid as customer_id, NULL as deal_id, 
					ST_Y(location::geometry) as lat, ST_X(location::geometry) as lon, 
					0.0 as distance, notes, timestamp_at as created_at, type,
					NULL as selfie_photo_path, NULL as place_photo_path
			FROM attendances
			WHERE 1=1
		`
		// Append same filters for user/date to the second part of union
		if filter.SalesID != nil {
			baseQuery += fmt.Sprintf(" AND user_id = $%d", 1) // Re-use SalesID arg
		}
		if filter.StartDate != nil {
			// Find arg index for StartDate
			idx := 1
			if filter.SalesID != nil { idx++ }
			baseQuery += fmt.Sprintf(" AND timestamp_at >= $%d", idx)
		}
		if filter.EndDate != nil {
			idx := 1
			if filter.SalesID != nil { idx++ }
			if filter.StartDate != nil { idx++ }
			baseQuery += fmt.Sprintf(" AND timestamp_at <= $%d", idx)
		}
	}

	baseQuery += ") AS unified_activities ORDER BY created_at DESC"

	rows, err := r.db.Query(ctx, baseQuery, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	return scanActivities(rows)
}
