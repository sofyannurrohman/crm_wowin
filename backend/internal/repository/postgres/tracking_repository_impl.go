package postgres

import (
	"context"
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"
	"encoding/json"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type trackingRepositoryImpl struct {
	db *pgxpool.Pool
}

func NewTrackingRepository(db *pgxpool.Pool) repository.TrackingRepository {
	return &trackingRepositoryImpl{db: db}
}

func (r *trackingRepositoryImpl) GetOrCreateSession(ctx context.Context, salesID uuid.UUID, date time.Time) (*models.TrackingSession, error) {
	query := `
		INSERT INTO tracking_sessions (sales_id, session_date, status)
		VALUES ($1, $2, 'idle')
		ON CONFLICT (sales_id, session_date) DO UPDATE
		SET updated_at = NOW()
		RETURNING id, sales_id, session_date, started_at, ended_at, status, total_distance, created_at, updated_at
	`
	var s models.TrackingSession
	err := r.db.QueryRow(ctx, query, salesID, date.Format("2006-01-02")).Scan(
		&s.ID, &s.SalesID, &s.SessionDate, &s.StartedAt, &s.EndedAt, &s.Status, &s.TotalDistance, &s.CreatedAt, &s.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}
	return &s, nil
}

func (r *trackingRepositoryImpl) GetSessionByID(ctx context.Context, id uuid.UUID) (*models.TrackingSession, error) {
	query := `
		SELECT id, sales_id, session_date, started_at, ended_at, status, total_distance, created_at, updated_at
		FROM tracking_sessions WHERE id = $1
	`
	var s models.TrackingSession
	err := r.db.QueryRow(ctx, query, id).Scan(
		&s.ID, &s.SalesID, &s.SessionDate, &s.StartedAt, &s.EndedAt, &s.Status, &s.TotalDistance, &s.CreatedAt, &s.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}
	return &s, nil
}

func (r *trackingRepositoryImpl) UpdateSession(ctx context.Context, s *models.TrackingSession) error {
	query := `
		UPDATE tracking_sessions 
		SET started_at = $1, ended_at = $2, status = $3, total_distance = $4, updated_at = NOW()
		WHERE id = $5
	`
	_, err := r.db.Exec(ctx, query, s.StartedAt, s.EndedAt, s.Status, s.TotalDistance, s.ID)
	return err
}

func (r *trackingRepositoryImpl) SaveBatchPoints(ctx context.Context, points []models.LocationPoint) error {
	if len(points) == 0 {
		return nil
	}

	// Use CopyFrom for high performance batch insert
	rows := [][]interface{}{}
	for _, p := range points {
		// PostGIS point from lat lon
		pointWKT := fmt.Sprintf("SRID=4326;POINT(%f %f)", p.Longitude, p.Latitude)
		rows = append(rows, []interface{}{
			p.SessionID, p.SalesID, p.RecordedAt, pointWKT, p.Accuracy, p.Speed, p.Heading, p.Altitude, p.BatteryLevel,
		})
	}

	_, err := r.db.CopyFrom(
		ctx,
		pgx.Identifier{"gps_points"},
		[]string{"session_id", "sales_id", "recorded_at", "location", "accuracy", "speed", "heading", "altitude", "battery_level"},
		pgx.CopyFromRows(rows),
	)
	
	// After batch insert, we should also trigger the route rebuild function in DB if needed
	// But it might be too heavy to do on every sync. For now, let's just insert points.
	
	return err
}

func (r *trackingRepositoryImpl) UpdateLivePosition(ctx context.Context, pos *models.SalesLivePosition) error {
	query := `
		INSERT INTO sales_live_positions (sales_id, location, status, speed, heading, battery_level, updated_at)
		VALUES ($1, ST_SetSRID(ST_Point($2, $3), 4326), $4, $5, $6, $7, NOW())
		ON CONFLICT (sales_id) DO UPDATE SET
			location = EXCLUDED.location,
			status = EXCLUDED.status,
			speed = EXCLUDED.speed,
			heading = EXCLUDED.heading,
			battery_level = EXCLUDED.battery_level,
			updated_at = NOW()
	`
	_, err := r.db.Exec(ctx, query, pos.SalesID, pos.Longitude, pos.Latitude, pos.Status, pos.Speed, pos.Heading, pos.BatteryLevel)
	return err
}

func (r *trackingRepositoryImpl) GetLivePositions(ctx context.Context) ([]models.SalesLivePosition, error) {
	query := `
		SELECT lp.sales_id, u.name as sales_name, ST_Y(lp.location) as lat, ST_X(lp.location) as lon, 
		       lp.status, lp.speed, lp.heading, lp.battery_level, lp.updated_at
		FROM sales_live_positions lp
		JOIN users u ON lp.sales_id = u.id
		WHERE lp.updated_at > NOW() - INTERVAL '1 hour'
	`
	rows, err := r.db.Query(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []models.SalesLivePosition
	for rows.Next() {
		var p models.SalesLivePosition
		err := rows.Scan(&p.SalesID, &p.SalesName, &p.Latitude, &p.Longitude, &p.Status, &p.Speed, &p.Heading, &p.BatteryLevel, &p.UpdatedAt)
		if err != nil {
			return nil, err
		}
		results = append(results, p)
	}
	return results, nil
}

func (r *trackingRepositoryImpl) GetRouteGeometry(ctx context.Context, sessionID uuid.UUID) (interface{}, error) {
	query := `SELECT ST_AsGeoJSON(route) FROM tracking_sessions WHERE id = $1`
	var geoJSONStr *string
	err := r.db.QueryRow(ctx, query, sessionID).Scan(&geoJSONStr)
	if err != nil {
		return nil, err
	}
	if geoJSONStr == nil {
		return nil, nil
	}

	var result interface{}
	err = json.Unmarshal([]byte(*geoJSONStr), &result)
	return result, err
}
