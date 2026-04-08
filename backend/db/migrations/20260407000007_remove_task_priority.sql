-- +goose Up
-- +goose StatementBegin
-- Remove priority column from tasks table
ALTER TABLE tasks DROP COLUMN IF EXISTS priority;

-- Drop the task_priority enum type
DROP TYPE IF EXISTS task_priority;

-- Align task_status values in task_destinations table (which was VARCHAR) to match lowercase
UPDATE task_destinations SET status = 'pending' WHERE status = 'TODO';
UPDATE task_destinations SET status = 'in_progress' WHERE status = 'IN_PROGRESS';
UPDATE task_destinations SET status = 'done' WHERE status = 'COMPLETED';
UPDATE task_destinations SET status = 'cancelled' WHERE status = 'CANCELLED';
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
-- Re-create the task_priority enum type
IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'task_priority') THEN
    CREATE TYPE task_priority AS ENUM ('low', 'medium', 'high', 'urgent');
END IF;

-- Re-add the priority column
ALTER TABLE tasks ADD COLUMN priority task_priority DEFAULT 'medium';

-- Note: Reversing status case change is not critical for Down migration
-- +goose StatementEnd
