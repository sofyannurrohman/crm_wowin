-- +goose Up
-- +goose StatementBegin
-- 1. Fix deal_items schema (missing columns expected by repo)
ALTER TABLE deal_items ADD COLUMN IF NOT EXISTS name VARCHAR(255);
-- unit was added in a previous migration but let's ensure it exists
ALTER TABLE deal_items ADD COLUMN IF NOT EXISTS unit VARCHAR(50) DEFAULT 'pcs';
-- The error reported 'column created_at does not exist', so we ensure it exists
ALTER TABLE deal_items ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- 2. Ensure deals has timestamps
ALTER TABLE deals ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
ALTER TABLE deals ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
ALTER TABLE deal_items DROP COLUMN IF EXISTS name;
ALTER TABLE deals DROP COLUMN IF EXISTS created_at;
ALTER TABLE deals DROP COLUMN IF EXISTS updated_at;
-- +goose StatementEnd
