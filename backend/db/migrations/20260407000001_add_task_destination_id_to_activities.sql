-- +goose Up
-- +goose StatementBegin
-- Add task_destination_id to visits to link it with Task multi-destination stops
-- (Note: 'visit_activities' was renamed to 'visits' in 20260401000002_reconcile_visits_table.sql)
ALTER TABLE visits ADD COLUMN IF NOT EXISTS task_destination_id UUID REFERENCES task_destinations(id);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_visits_task_destination_id ON visits(task_destination_id);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP INDEX IF EXISTS idx_visits_task_destination_id;
ALTER TABLE visits DROP COLUMN IF EXISTS task_destination_id;
-- +goose StatementEnd
