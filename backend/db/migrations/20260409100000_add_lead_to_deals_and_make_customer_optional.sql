-- +goose Up
-- +goose StatementBegin
-- 1. Make customer_id nullable in deals table
ALTER TABLE deals ALTER COLUMN customer_id DROP NOT NULL;

-- 2. Add lead_id column to deals table
ALTER TABLE deals ADD COLUMN lead_id UUID REFERENCES leads(id) ON DELETE SET NULL;

-- 3. Make deal_id nullable in deal_items table (optional, but helps with some batch creation flows)
ALTER TABLE deal_items ALTER COLUMN deal_id DROP NOT NULL;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
-- 1. Restore NOT NULL constraint (may fail if null values exist)
-- UPDATE deals SET customer_id = '00000000-0000-0000-0000-000000000000' WHERE customer_id IS NULL;
ALTER TABLE deals ALTER COLUMN customer_id SET NOT NULL;

-- 2. Remove lead_id column
ALTER TABLE deals DROP COLUMN lead_id;

-- 3. Restore NOT NULL constraint on deal_items
ALTER TABLE deal_items ALTER COLUMN deal_id SET NOT NULL;
-- +goose StatementEnd
