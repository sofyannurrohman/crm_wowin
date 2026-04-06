-- +goose Up
-- +goose StatementBegin
DO $$ 
BEGIN 
    -- Rename "date" to "scheduled_date" only if "date" exists
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'visit_schedules' AND column_name = 'date') THEN
        ALTER TABLE visit_schedules RENAME COLUMN "date" TO "scheduled_date";
    END IF;

    -- Add deal_id only if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'visit_schedules' AND column_name = 'deal_id') THEN
        ALTER TABLE visit_schedules ADD COLUMN "deal_id" UUID REFERENCES deals(id) ON DELETE SET NULL;
    END IF;
END $$;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DO $$
BEGIN
    -- Drop deal_id if it exists
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'visit_schedules' AND column_name = 'deal_id') THEN
        ALTER TABLE visit_schedules DROP COLUMN "deal_id";
    END IF;

    -- Rename "scheduled_date" back to "date" only if "scheduled_date" exists and "date" doesn't
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'visit_schedules' AND column_name = 'scheduled_date') 
       AND NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'visit_schedules' AND column_name = 'date') THEN
        ALTER TABLE visit_schedules RENAME COLUMN "scheduled_date" TO "date";
    END IF;
END $$;
-- +goose StatementEnd
