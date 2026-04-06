-- +goose Up
-- +goose StatementBegin
ALTER TABLE tasks ADD COLUMN warehouse_id UUID REFERENCES warehouses(id) ON DELETE SET NULL;

-- Assign first available warehouse to existing tasks to avoid null constraints later if needed
UPDATE tasks SET warehouse_id = (SELECT id FROM warehouses ORDER BY created_at LIMIT 1)
WHERE warehouse_id IS NULL AND (SELECT COUNT(*) FROM warehouses) > 0;

-- Optional: Make it NOT NULL for future tasks if desired
-- ALTER TABLE tasks ALTER COLUMN warehouse_id SET NOT NULL;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
ALTER TABLE tasks DROP COLUMN warehouse_id;
-- +goose StatementEnd
