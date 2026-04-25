-- +goose Up
-- +goose StatementBegin
DO $$ BEGIN
    CREATE TYPE visit_workflow_status AS ENUM ('DRAFT_PHOTO', 'COMPLETED');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
-- +goose StatementEnd

-- 2. Add status and nota_photo_path to sales_activities
ALTER TABLE sales_activities 
ADD COLUMN IF NOT EXISTS status visit_workflow_status NOT NULL DEFAULT 'COMPLETED',
ADD COLUMN IF NOT EXISTS nota_photo_path TEXT;

-- 3. Backfill status for existing records
UPDATE sales_activities SET status = 'COMPLETED' WHERE status IS NULL;

-- +goose Down
ALTER TABLE sales_activities DROP COLUMN IF EXISTS status;
ALTER TABLE sales_activities DROP COLUMN IF EXISTS nota_photo_path;
DROP TYPE IF EXISTS visit_workflow_status;

