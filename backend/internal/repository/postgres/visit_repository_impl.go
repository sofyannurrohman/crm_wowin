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
	query := `SELECT vs.id, vs.sales_id, vs.lead_id, vs.customer_id, vs.deal_id, vs.scheduled_date, 
					 vs.title, vs.objective, vs.status, vs.notes, vs.created_at, vs.updated_at,
					 u.name as sales_name, c.name as customer_name
			  FROM visit_schedules vs
			  LEFT JOIN users u ON vs.sales_id = u.id
			  LEFT JOIN customers c ON vs.customer_id = c.id
			  WHERE vs.id=$1`
	var s models.VisitSchedule
	var salesName, customerName *string
	err := r.db.QueryRow(ctx, query, id).Scan(
		&s.ID, &s.SalesID, &s.LeadID, &s.CustomerID, &s.DealID, &s.Date, 
		&s.Title, &s.Objective, &s.Status, &s.Notes, &s.CreatedAt, &s.UpdatedAt,
		&salesName, &customerName,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, dberrors.ErrNotFound
	}
	if salesName != nil { s.SalesName = *salesName }
	if customerName != nil { s.CustomerName = *customerName }
	return &s, err
}

func (r *visitRepoImpl) ListSchedules(ctx context.Context, filter repository.ScheduleFilter) ([]*models.VisitSchedule, error) {
	baseQuery := `SELECT vs.id, vs.sales_id, vs.lead_id, vs.customer_id, vs.deal_id, vs.scheduled_date, 
						 vs.title, vs.objective, vs.status, vs.notes, vs.created_at, vs.updated_at,
						 u.name as sales_name, c.name as customer_name
				  FROM visit_schedules vs
				  LEFT JOIN users u ON vs.sales_id = u.id
				  LEFT JOIN customers c ON vs.customer_id = c.id
				  WHERE 1=1`

	args := []interface{}{}
	argCount := 1

	if filter.SalesID != nil {
		baseQuery += fmt.Sprintf(" AND vs.sales_id = $%d", argCount)
		args = append(args, *filter.SalesID)
		argCount++
	}
	if filter.LeadID != nil {
		baseQuery += fmt.Sprintf(" AND vs.lead_id = $%d", argCount)
		args = append(args, *filter.LeadID)
		argCount++
	}
	if filter.CustomerID != nil {
		baseQuery += fmt.Sprintf(" AND vs.customer_id = $%d", argCount)
		args = append(args, *filter.CustomerID)
		argCount++
	}
	if filter.StartDate != nil {
		baseQuery += fmt.Sprintf(" AND vs.scheduled_date >= $%d", argCount)
		args = append(args, *filter.StartDate)
		argCount++
	}
	if filter.EndDate != nil {
		baseQuery += fmt.Sprintf(" AND vs.scheduled_date <= $%d", argCount)
		args = append(args, *filter.EndDate)
		argCount++
	}

	baseQuery += " ORDER BY vs.scheduled_date ASC, vs.created_at ASC"

	rows, err := r.db.Query(ctx, baseQuery, args...)
	if err != nil {
		fmt.Printf("❌ Database query error (ListSchedules): %v\n", err)
		return nil, err
	}
	defer rows.Close()

	var results []*models.VisitSchedule
	for rows.Next() {
		var s models.VisitSchedule
		var salesName, customerName *string
		err := rows.Scan(
			&s.ID, &s.SalesID, &s.LeadID, &s.CustomerID, &s.DealID, &s.Date, 
			&s.Title, &s.Objective, &s.Status, &s.Notes, &s.CreatedAt, &s.UpdatedAt,
			&salesName, &customerName,
		)
		if err != nil {
			fmt.Printf("❌ Database scan error (ListSchedules): %v\n", err)
			return nil, err
		}
		if salesName != nil { s.SalesName = *salesName }
		if customerName != nil { s.CustomerName = *customerName }
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
		// Parameters: $1=Longitude, $2=Latitude, $3=Notes, $4=ScheduleID,
		//             $5=TaskDestinationID, $6=CustomerID, $7=LeadID, $8=SalesID,
		//             $9=PlacePhotoPath, $10=NotaPhotoPath
		query := `UPDATE visits SET 
					checkout_at = NOW(),
					checkout_location = ST_SetSRID(ST_MakePoint($1, $2), 4326),
					status = CASE WHEN $10::text IS NOT NULL AND $10 != '' THEN 'DRAFT_PHOTO' ELSE 'completed' END,
					result_notes = CASE WHEN $3::text IS NOT NULL THEN COALESCE(result_notes || E'\n' || $3, $3) ELSE result_notes END,
					place_photo_path = COALESCE($9, place_photo_path),
					nota_photo_path = CASE WHEN $10::text IS NOT NULL AND $10 != '' THEN $10 ELSE nota_photo_path END
				  WHERE (
					($4::uuid IS NOT NULL AND schedule_id = $4) OR 
					($5::uuid IS NOT NULL AND task_destination_id = $5) OR 
					($6::uuid IS NOT NULL AND customer_id = $6 AND sales_id = $8) OR 
					($7::uuid IS NOT NULL AND lead_id = $7 AND sales_id = $8)
				  ) 
				  AND checkout_at IS NULL
				  RETURNING id, created_at`
		err := r.db.QueryRow(ctx, query,
			a.Longitude, a.Latitude, a.Notes, a.ScheduleID, a.TaskDestinationID,
			a.CustomerID, a.LeadID, a.SalesID, a.PlacePhotoPath, a.NotaPhotoPath,
		).Scan(&a.ID, &a.CreatedAt)
		if errors.Is(err, pgx.ErrNoRows) {
			return fmt.Errorf("no active check-in found for this target: %w", dberrors.ErrNotFound)
		}
		return err
	}
}

func (r *visitRepoImpl) GetActivitiesBySchedule(ctx context.Context, scheduleID uuid.UUID) ([]*models.VisitActivity, error) {
	query := `
		SELECT v.id, v.schedule_id, v.task_destination_id, v.sales_id, v.lead_id, v.customer_id, v.deal_id,
			ST_Y(v.checkin_location::geometry) as lat, ST_X(v.checkin_location::geometry) as lon,
			v.checkin_distance as distance, v.result_notes as notes, v.created_at,
			CASE WHEN v.checkout_at IS NULL THEN 'check-in' ELSE 'check-out' END as type,
			v.selfie_photo_path, v.place_photo_path, COALESCE(v.status, 'completed') as status,
			v.nota_photo_path, c.name as customer_name, l.name as lead_name
		FROM visits v
		LEFT JOIN customers c ON v.customer_id = c.id
		LEFT JOIN leads l ON v.lead_id = l.id
		WHERE v.schedule_id=$1 ORDER BY v.created_at ASC
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
		SELECT v.id, v.schedule_id, v.task_destination_id, v.sales_id, v.lead_id, v.customer_id, v.deal_id,
			ST_Y(v.checkin_location::geometry) as lat, ST_X(v.checkin_location::geometry) as lon,
			v.checkin_distance as distance, v.result_notes as notes, v.created_at,
			CASE WHEN v.checkout_at IS NULL THEN 'check-in' ELSE 'check-out' END as type,
			v.selfie_photo_path, v.place_photo_path, COALESCE(v.status, 'completed') as status,
			v.nota_photo_path, c.name as customer_name, l.name as lead_name
		FROM visits v
		LEFT JOIN customers c ON v.customer_id = c.id
		LEFT JOIN leads l ON v.lead_id = l.id
		WHERE v.customer_id=$1 ORDER BY v.created_at DESC
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
		SELECT v.id, v.schedule_id, v.task_destination_id, v.sales_id, v.lead_id, v.customer_id, v.deal_id,
			ST_Y(v.checkin_location::geometry) as lat, ST_X(v.checkin_location::geometry) as lon,
			v.checkin_distance as distance, v.result_notes as notes, v.created_at,
			CASE WHEN v.checkout_at IS NULL THEN 'check-in' ELSE 'check-out' END as type,
			v.selfie_photo_path, v.place_photo_path, COALESCE(v.status, 'completed') as status,
			v.nota_photo_path, c.name as customer_name, l.name as lead_name
		FROM visits v
		LEFT JOIN customers c ON v.customer_id = c.id
		LEFT JOIN leads l ON v.lead_id = l.id
		WHERE v.lead_id=$1 ORDER BY v.created_at DESC
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
		var selfie, place, notaPhoto, customerName, leadName *string
		err := rows.Scan(
			&a.ID, &a.ScheduleID, &a.TaskDestinationID, &a.SalesID, &a.LeadID, &a.CustomerID, &a.DealID,
			&a.Latitude, &a.Longitude,
			&a.Distance, &a.Notes, &a.CreatedAt, &a.Type,
			&selfie, &place, &a.Status, &notaPhoto,
			&customerName, &leadName,
		)
		if err != nil {
			return nil, err
		}
		if selfie != nil { a.SelfiePhotoPath = *selfie }
		if place != nil { a.PlacePhotoPath = *place }
		if notaPhoto != nil { a.NotaPhotoPath = *notaPhoto }
		if customerName != nil { a.CustomerName = *customerName }
		if leadName != nil { a.LeadName = *leadName }
		results = append(results, &a)
	}
	return results, nil
}

func (r *visitRepoImpl) ListActivities(ctx context.Context, filter repository.ActivityFilter) ([]*models.VisitActivity, error) {
	baseQuery := `
		SELECT
			v.id, v.schedule_id, v.task_destination_id, v.sales_id, v.lead_id, v.customer_id, v.deal_id,
			ST_Y(v.checkin_location::geometry) as lat,
			ST_X(v.checkin_location::geometry) as lon,
			v.checkin_distance as distance,
			v.result_notes as notes,
			v.created_at,
			CASE WHEN v.checkout_at IS NULL THEN 'check-in' ELSE 'check-out' END as type,
			v.selfie_photo_path,
			v.place_photo_path,
			COALESCE(v.status, 'completed') as status,
			v.nota_photo_path,
			c.name as customer_name,
			l.name as lead_name
		FROM visits v
		LEFT JOIN customers c ON v.customer_id = c.id
		LEFT JOIN leads l ON v.lead_id = l.id
		WHERE 1=1
	`
	args := []interface{}{}
	argCount := 1

	if filter.SalesID != nil {
		baseQuery += fmt.Sprintf(" AND v.sales_id = $%d", argCount)
		args = append(args, *filter.SalesID)
		argCount++
	}
	if filter.LeadID != nil {
		baseQuery += fmt.Sprintf(" AND v.lead_id = $%d", argCount)
		args = append(args, *filter.LeadID)
		argCount++
	}
	if filter.CustomerID != nil {
		baseQuery += fmt.Sprintf(" AND v.customer_id = $%d", argCount)
		args = append(args, *filter.CustomerID)
		argCount++
	}
	if filter.StartDate != nil {
		baseQuery += fmt.Sprintf(" AND v.created_at >= $%d", argCount)
		args = append(args, *filter.StartDate)
		argCount++
	}
	if filter.EndDate != nil {
		baseQuery += fmt.Sprintf(" AND v.created_at <= $%d", argCount)
		args = append(args, *filter.EndDate)
		argCount++
	}

	baseQuery += " ORDER BY v.created_at DESC"

	rows, err := r.db.Query(ctx, baseQuery, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	return scanActivities(rows)
}
