package postgres

import (
	"context"
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
)

type attendanceRepositoryImpl struct {
	db *pgxpool.Pool
}

func NewAttendanceRepository(db *pgxpool.Pool) repository.AttendanceRepository {
	return &attendanceRepositoryImpl{db: db}
}

func (r *attendanceRepositoryImpl) Create(ctx context.Context, a *models.Attendance) error {
	query := `
		INSERT INTO attendances (user_id, type, location, address, photo_path, device_info, notes, timestamp_at)
		VALUES ($1, $2, ST_SetSRID(ST_Point($3, $4), 4326), $5, $6, $7, $8, NOW())
		RETURNING id, timestamp_at
	`
	return r.db.QueryRow(ctx, query, a.UserID, a.Type, a.Longitude, a.Latitude, a.Address, a.PhotoPath, a.DeviceInfo, a.Notes).
		Scan(&a.ID, &a.TimestampAt)
}

func (r *attendanceRepositoryImpl) GetLatestByUserID(ctx context.Context, userID uuid.UUID, date time.Time) (*models.Attendance, error) {
	query := `
		SELECT id, user_id, type, ST_Y(location), ST_X(location), address, photo_path, device_info, notes, timestamp_at
		FROM attendances
		WHERE user_id = $1 AND DATE(timestamp_at) = $2
		ORDER BY timestamp_at DESC
		LIMIT 1
	`
	var a models.Attendance
	err := r.db.QueryRow(ctx, query, userID, date.Format("2006-01-02")).Scan(
		&a.ID, &a.UserID, &a.Type, &a.Latitude, &a.Longitude, &a.Address, &a.PhotoPath, &a.DeviceInfo, &a.Notes, &a.TimestampAt,
	)
	if err != nil {
		return nil, err
	}
	return &a, nil
}

func (r *attendanceRepositoryImpl) ListByUser(ctx context.Context, userID uuid.UUID, startDate, endDate time.Time) ([]models.Attendance, error) {
	query := `
		SELECT id, user_id, type, ST_Y(location), ST_X(location), address, photo_path, device_info, notes, timestamp_at
		FROM attendances
		WHERE user_id = $1 AND timestamp_at BETWEEN $2 AND $3
		ORDER BY timestamp_at DESC
	`
	rows, err := r.db.Query(ctx, query, userID, startDate, endDate)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []models.Attendance
	for rows.Next() {
		var a models.Attendance
		err := rows.Scan(&a.ID, &a.UserID, &a.Type, &a.Latitude, &a.Longitude, &a.Address, &a.PhotoPath, &a.DeviceInfo, &a.Notes, &a.TimestampAt)
		if err != nil {
			return nil, err
		}
		results = append(results, a)
	}
	return results, nil
}

func (r *attendanceRepositoryImpl) GetDailySummary(ctx context.Context, userID uuid.UUID, startDate, endDate time.Time) ([]models.DailyAttendance, error) {
	query := `
		SELECT user_id, work_date, clock_in, clock_out, work_hours
		FROM daily_attendance
		WHERE user_id = $1 AND work_date BETWEEN $2 AND $3
		ORDER BY work_date DESC
	`
	rows, err := r.db.Query(ctx, query, userID, startDate.Format("2006-01-02"), endDate.Format("2006-01-02"))
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []models.DailyAttendance
	for rows.Next() {
		var d models.DailyAttendance
		err := rows.Scan(&d.UserID, &d.WorkDate, &d.ClockIn, &d.ClockOut, &d.WorkHours)
		if err != nil {
			return nil, err
		}
		results = append(results, d)
	}
	return results, nil
}
