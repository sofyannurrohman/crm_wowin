package postgres

import (
	"context"
	"crm_wowin_backend/internal/domain/models"
	"crm_wowin_backend/internal/domain/repository"
	"fmt"

	"github.com/google/uuid"
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
		INSERT INTO tasks (sales_id, customer_id, title, description, priority, status, due_date)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
		RETURNING id, created_at, updated_at
	`
	return r.db.QueryRow(ctx, query, t.SalesID, t.CustomerID, t.Title, t.Description, t.Priority, t.Status, t.DueDate).
		Scan(&t.ID, &t.CreatedAt, &t.UpdatedAt)
}

func (r *taskRepoImpl) GetByID(ctx context.Context, id uuid.UUID) (*models.Task, error) {
	query := `
		SELECT t.id, t.sales_id, t.customer_id, c.name as customer_name, t.title, t.description, t.priority, t.status, t.due_date, t.completed_at, t.created_at, t.updated_at
		FROM tasks t
		LEFT JOIN customers c ON t.customer_id = c.id
		WHERE t.id = $1
	`
	var t models.Task
	err := r.db.QueryRow(ctx, query, id).Scan(
		&t.ID, &t.SalesID, &t.CustomerID, &t.CustomerName, &t.Title, &t.Description, &t.Priority, &t.Status, &t.DueDate, &t.CompletedAt, &t.CreatedAt, &t.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}
	return &t, nil
}

func (r *taskRepoImpl) List(ctx context.Context, filter repository.TaskFilter) ([]*models.Task, error) {
	baseQuery := `
		SELECT t.id, t.sales_id, t.customer_id, c.name as customer_name, t.title, t.description, t.priority, t.status, t.due_date, t.completed_at, t.created_at, t.updated_at
		FROM tasks t
		LEFT JOIN customers c ON t.customer_id = c.id
		WHERE 1=1
	`
	args := []interface{}{}
	argIdx := 1

	if filter.SalesID != nil {
		baseQuery += fmt.Sprintf(" AND t.sales_id = $%d", argIdx)
		args = append(args, *filter.SalesID)
		argIdx++
	}
	if filter.CustomerID != nil {
		baseQuery += fmt.Sprintf(" AND t.customer_id = $%d", argIdx)
		args = append(args, *filter.CustomerID)
		argIdx++
	}
	if filter.Status != "" {
		baseQuery += fmt.Sprintf(" AND t.status = $%d", argIdx)
		args = append(args, filter.Status)
		argIdx++
	}

	baseQuery += " ORDER BY t.due_date ASC, t.created_at DESC"

	rows, err := r.db.Query(ctx, baseQuery, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var tasks []*models.Task
	for rows.Next() {
		var t models.Task
		err := rows.Scan(
			&t.ID, &t.SalesID, &t.CustomerID, &t.CustomerName, &t.Title, &t.Description, &t.Priority, &t.Status, &t.DueDate, &t.CompletedAt, &t.CreatedAt, &t.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		tasks = append(tasks, &t)
	}
	return tasks, nil
}

func (r *taskRepoImpl) Update(ctx context.Context, t *models.Task) error {
	query := `
		UPDATE tasks
		SET customer_id = $1, title = $2, description = $3, priority = $4, status = $5, due_date = $6, completed_at = $7, updated_at = CURRENT_TIMESTAMP
		WHERE id = $8
	`
	_, err := r.db.Exec(ctx, query, t.CustomerID, t.Title, t.Description, t.Priority, t.Status, t.DueDate, t.CompletedAt, t.ID)
	return err
}

func (r *taskRepoImpl) Delete(ctx context.Context, id uuid.UUID) error {
	_, err := r.db.Exec(ctx, "DELETE FROM tasks WHERE id = $1", id)
	return err
}
