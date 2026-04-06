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
		INSERT INTO tasks (sales_id, warehouse_id, title, description, priority, status, due_date)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
		RETURNING id, created_at, updated_at
	`
	err := r.db.QueryRow(ctx, query, t.SalesID, t.WarehouseID, t.Title, t.Description, t.Priority, t.Status, t.DueDate).
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
		dQuery := `INSERT INTO task_destinations (task_id, lead_id, customer_id, sequence_order, status)
				   VALUES ($1, $2, $3, $4, $5) RETURNING id, created_at, updated_at`
		r.db.QueryRow(ctx, dQuery, t.ID, t.Destinations[i].LeadID, t.Destinations[i].CustomerID, t.Destinations[i].SequenceOrder, qStatus).
			Scan(&t.Destinations[i].ID, &t.Destinations[i].CreatedAt, &t.Destinations[i].UpdatedAt)
	}
	return nil
}

func (r *taskRepoImpl) GetByID(ctx context.Context, id uuid.UUID) (*models.Task, error) {
	query := `
		SELECT t.id, t.sales_id, t.warehouse_id, t.title, t.description, t.priority, t.status, t.due_date, t.completed_at, t.created_at, t.updated_at,
		       w.id, w.name, w.address, w.latitude, w.longitude
		FROM tasks t
		LEFT JOIN warehouses w ON t.warehouse_id = w.id
		WHERE t.id = $1
	`
	var t models.Task
	var w models.Warehouse
	err := r.db.QueryRow(ctx, query, id).Scan(
		&t.ID, &t.SalesID, &t.WarehouseID, &t.Title, &t.Description, &t.Priority, &t.Status, &t.DueDate, &t.CompletedAt, &t.CreatedAt, &t.UpdatedAt,
		&w.ID, &w.Name, &w.Address, &w.Latitude, &w.Longitude,
	)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil // Or handle as not found
		}
		return nil, err
	}
	t.Warehouse = &w

	dQuery := `SELECT id, task_id, lead_id, customer_id, sequence_order, status, created_at, updated_at
			   FROM task_destinations WHERE task_id = $1 ORDER BY sequence_order ASC`
	rows, _ := r.db.Query(ctx, dQuery, id)
	defer rows.Close()
	t.Destinations = []models.TaskDestination{}
	for rows.Next() {
		var td models.TaskDestination
		rows.Scan(&td.ID, &td.TaskID, &td.LeadID, &td.CustomerID, &td.SequenceOrder, &td.Status, &td.CreatedAt, &td.UpdatedAt)
		t.Destinations = append(t.Destinations, td)
	}

	return &t, nil
}

func (r *taskRepoImpl) List(ctx context.Context, filter repository.TaskFilter) ([]*models.Task, error) {
	baseQuery := `
		SELECT t.id, t.sales_id, t.warehouse_id, t.title, t.description, t.priority, t.status, t.due_date, t.completed_at, t.created_at, t.updated_at,
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
			&t.ID, &t.SalesID, &t.WarehouseID, &t.Title, &t.Description, &t.Priority, &t.Status, &t.DueDate, &t.CompletedAt, &t.CreatedAt, &t.UpdatedAt,
			&w.ID, &w.Name, &w.Address, &w.Latitude, &w.Longitude,
		)
		if err == nil {
			t.Warehouse = &w
		}
		if err != nil {
			return nil, err
		}
		
		dQuery := `SELECT id, task_id, lead_id, customer_id, sequence_order, status, created_at, updated_at
				   FROM task_destinations WHERE task_id = $1 ORDER BY sequence_order ASC`
		dRows, _ := r.db.Query(ctx, dQuery, t.ID)
		t.Destinations = []models.TaskDestination{}
		for dRows.Next() {
			var td models.TaskDestination
			dRows.Scan(&td.ID, &td.TaskID, &td.LeadID, &td.CustomerID, &td.SequenceOrder, &td.Status, &td.CreatedAt, &td.UpdatedAt)
			t.Destinations = append(t.Destinations, td)
		}
		dRows.Close()

		tasks = append(tasks, &t)
	}
	return tasks, nil
}

func (r *taskRepoImpl) Update(ctx context.Context, t *models.Task) error {
	query := `
		UPDATE tasks
		SET warehouse_id = $1, title = $2, description = $3, priority = $4, status = $5, due_date = $6, completed_at = $7, updated_at = CURRENT_TIMESTAMP
		WHERE id = $8
	`
	_, err := r.db.Exec(ctx, query, t.WarehouseID, t.Title, t.Description, t.Priority, t.Status, t.DueDate, t.CompletedAt, t.ID)
	// (Skipping deep update of destinations for simplicity/MVP, assume frontend resends fully or uses separate endpoint)
	return err
}

func (r *taskRepoImpl) Delete(ctx context.Context, id uuid.UUID) error {
	_, err := r.db.Exec(ctx, "DELETE FROM tasks WHERE id = $1", id)
	return err
}
