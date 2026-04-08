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

type taskRepoImpl struct {
	db *pgxpool.Pool
}

func NewTaskRepository(db *pgxpool.Pool) repository.TaskRepository {
	return &taskRepoImpl{db: db}
}

func (r *taskRepoImpl) Create(ctx context.Context, t *models.Task) error {
	query := `
		INSERT INTO tasks (sales_id, warehouse_id, title, description, status, due_date)
		VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING id, created_at, updated_at
	`
	err := r.db.QueryRow(ctx, query, t.SalesID, t.WarehouseID, t.Title, t.Description, t.Status, t.DueDate).
		Scan(&t.ID, &t.CreatedAt, &t.UpdatedAt)
	if err != nil {
		return err
	}

	for i := range t.Destinations {
		t.Destinations[i].TaskID = t.ID
		t.Destinations[i].SequenceOrder = i + 1
		qStatus := t.Destinations[i].Status
		if qStatus == "" {
			qStatus = models.TaskStatusTodo
		}
		dQuery := `INSERT INTO task_destinations (task_id, lead_id, customer_id, deal_id, sequence_order, status)
				   VALUES ($1, $2, $3, $4, $5, $6) RETURNING id, created_at, updated_at`
		r.db.QueryRow(ctx, dQuery, t.ID, t.Destinations[i].LeadID, t.Destinations[i].CustomerID, t.Destinations[i].DealID, t.Destinations[i].SequenceOrder, qStatus).
			Scan(&t.Destinations[i].ID, &t.Destinations[i].CreatedAt, &t.Destinations[i].UpdatedAt)
	}
	return nil
}

func (r *taskRepoImpl) GetByID(ctx context.Context, id uuid.UUID) (*models.Task, error) {
	query := `
		SELECT t.id, t.sales_id, t.warehouse_id, t.title, t.description, t.status, t.due_date, t.completed_at, t.created_at, t.updated_at,
		       w.id, w.name, w.address, w.latitude, w.longitude
		FROM tasks t
		LEFT JOIN warehouses w ON t.warehouse_id = w.id
		WHERE t.id = $1
	`
	var t models.Task
	var w models.Warehouse
	err := r.db.QueryRow(ctx, query, id).Scan(
		&t.ID, &t.SalesID, &t.WarehouseID, &t.Title, &t.Description, &t.Status, &t.DueDate, &t.CompletedAt, &t.CreatedAt, &t.UpdatedAt,
		&w.ID, &w.Name, &w.Address, &w.Latitude, &w.Longitude,
	)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil 
		}
		return nil, err
	}
	t.Warehouse = &w

	// Get Destinations with joined names and locations
	dQuery := `
		SELECT td.id, td.task_id, td.lead_id, td.customer_id, td.deal_id, td.sequence_order, td.status, td.created_at, td.updated_at,
		       COALESCE(l.name, c.name) as target_name,
		       COALESCE(l.latitude, c.latitude) as target_lat,
		       COALESCE(l.longitude, c.longitude) as target_lng,
		       COALESCE(l.address, c.address) as target_address
		FROM task_destinations td
		LEFT JOIN leads l ON td.lead_id = l.id
		LEFT JOIN customers c ON td.customer_id = c.id
		WHERE td.task_id = $1 
		ORDER BY td.sequence_order ASC`
	
	rows, err := r.db.Query(ctx, dQuery, id)
	if err != nil {
		return &t, nil // Return partial if destinations fail
	}
	defer rows.Close()
	
	t.Destinations = []models.TaskDestination{}
	for rows.Next() {
		var td models.TaskDestination
		err := rows.Scan(
			&td.ID, &td.TaskID, &td.LeadID, &td.CustomerID, &td.DealID, &td.SequenceOrder, &td.Status, &td.CreatedAt, &td.UpdatedAt,
			&td.TargetName, &td.TargetLatitude, &td.TargetLongitude, &td.TargetAddress,
		)
		if err == nil {
			t.Destinations = append(t.Destinations, td)
		}
	}

	return &t, nil
}

func (r *taskRepoImpl) GetByDestinationID(ctx context.Context, destID uuid.UUID) (*models.Task, error) {
	var taskID uuid.UUID
	err := r.db.QueryRow(ctx, "SELECT task_id FROM task_destinations WHERE id = $1", destID).Scan(&taskID)
	if err != nil {
		return nil, err
	}
	return r.GetByID(ctx, taskID)
}

func (r *taskRepoImpl) List(ctx context.Context, filter repository.TaskFilter) ([]*models.Task, error) {
	baseQuery := `
		SELECT t.id, t.sales_id, t.warehouse_id, t.title, t.description, t.status, t.due_date, t.completed_at, t.created_at, t.updated_at,
		       w.id, w.name, w.address, w.latitude, w.longitude
		FROM tasks t
		LEFT JOIN warehouses w ON t.warehouse_id = w.id
		WHERE 1=1
	`
	args := []interface{}{}
	argIdx := 1

	if filter.SalesID != nil {
		baseQuery += fmt.Sprintf(" AND sales_id = $%d", argIdx)
		args = append(args, *filter.SalesID)
		argIdx++
	}
	// Note: filter by CustomerID requires join with task_destinations now
	if filter.CustomerID != nil {
		baseQuery += fmt.Sprintf(" AND id IN (SELECT task_id FROM task_destinations WHERE customer_id = $%d)", argIdx)
		args = append(args, *filter.CustomerID)
		argIdx++
	}
	if filter.Status != "" {
		baseQuery += fmt.Sprintf(" AND t.status = $%d", argIdx)
		args = append(args, filter.Status)
		argIdx++
	}

	baseQuery += " ORDER BY due_date ASC, created_at DESC"

	rows, err := r.db.Query(ctx, baseQuery, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var tasks []*models.Task
	for rows.Next() {
		var t models.Task
		var w models.Warehouse
		err := rows.Scan(
			&t.ID, &t.SalesID, &t.WarehouseID, &t.Title, &t.Description, &t.Status, &t.DueDate, &t.CompletedAt, &t.CreatedAt, &t.UpdatedAt,
			&w.ID, &w.Name, &w.Address, &w.Latitude, &w.Longitude,
		)
		if err == nil {
			t.Warehouse = &w
		}
		if err != nil {
			return nil, err
		}
		
		dQuery := `
			SELECT td.id, td.task_id, td.lead_id, td.customer_id, td.deal_id, td.sequence_order, td.status, td.created_at, td.updated_at,
			       COALESCE(l.name, c.name) as target_name,
			       COALESCE(l.latitude, c.latitude) as target_lat,
			       COALESCE(l.longitude, c.longitude) as target_lng,
			       COALESCE(l.address, c.address) as target_address
			FROM task_destinations td
			LEFT JOIN leads l ON td.lead_id = l.id
			LEFT JOIN customers c ON td.customer_id = c.id
			WHERE td.task_id = $1 
			ORDER BY td.sequence_order ASC`
		dRows, _ := r.db.Query(ctx, dQuery, t.ID)
		t.Destinations = []models.TaskDestination{}
		for dRows.Next() {
			var td models.TaskDestination
			err := dRows.Scan(
				&td.ID, &td.TaskID, &td.LeadID, &td.CustomerID, &td.DealID, &td.SequenceOrder, &td.Status, &td.CreatedAt, &td.UpdatedAt,
				&td.TargetName, &td.TargetLatitude, &td.TargetLongitude, &td.TargetAddress,
			)
			if err == nil {
				t.Destinations = append(t.Destinations, td)
			}
		}
		dRows.Close()

		tasks = append(tasks, &t)
	}
	return tasks, nil
}

func (r *taskRepoImpl) Update(ctx context.Context, t *models.Task) error {
	tx, err := r.db.Begin(ctx)
	if err != nil {
		return err
	}
	defer tx.Rollback(ctx)

	query := `
		UPDATE tasks
		SET warehouse_id = $1, title = $2, description = $3, status = $4, due_date = $5, completed_at = $6, updated_at = CURRENT_TIMESTAMP
		WHERE id = $7
	`
	_, err = tx.Exec(ctx, query, t.WarehouseID, t.Title, t.Description, t.Status, t.DueDate, t.CompletedAt, t.ID)
	if err != nil {
		return err
	}

	// Update existing destinations status/order
	for _, d := range t.Destinations {
		dQuery := `UPDATE task_destinations SET status = $1, sequence_order = $2, updated_at = NOW() WHERE id = $3`
		_, err = tx.Exec(ctx, dQuery, d.Status, d.SequenceOrder, d.ID)
		if err != nil {
			return err
		}
	}

	return tx.Commit(ctx)
}

func (r *taskRepoImpl) Delete(ctx context.Context, id uuid.UUID) error {
	_, err := r.db.Exec(ctx, "DELETE FROM tasks WHERE id = $1", id)
	return err
}
