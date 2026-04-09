-- +goose Up
-- +goose StatementBegin
DO $$
BEGIN
    -- 1. Updates for visit_schedules
    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'visit_schedules' AND column_name = 'lead_id') THEN
        ALTER TABLE visit_schedules ADD COLUMN lead_id UUID REFERENCES leads(id) ON DELETE SET NULL;
    END IF;

    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'visit_schedules' AND column_name = 'deal_id') THEN
        ALTER TABLE visit_schedules ADD COLUMN deal_id UUID REFERENCES deals(id) ON DELETE SET NULL;
    END IF;

    ALTER TABLE visit_schedules ALTER COLUMN customer_id DROP NOT NULL;

    -- 2. Updates for visits
    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'visits' AND column_name = 'lead_id') THEN
        ALTER TABLE visits ADD COLUMN lead_id UUID REFERENCES leads(id) ON DELETE SET NULL;
    END IF;

    IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'visits' AND column_name = 'task_destination_id') THEN
        ALTER TABLE visits ADD COLUMN task_destination_id UUID; -- REFERENCES task_destinations(id) ON DELETE SET NULL;
    END IF;

    ALTER TABLE visits ALTER COLUMN customer_id DROP NOT NULL;
END $$;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
ALTER TABLE visits DROP COLUMN IF EXISTS lead_id;
ALTER TABLE visits DROP COLUMN IF EXISTS task_destination_id;
ALTER TABLE visits ALTER COLUMN customer_id SET NOT NULL;

ALTER TABLE visit_schedules DROP COLUMN IF EXISTS lead_id;
ALTER TABLE visit_schedules DROP COLUMN IF EXISTS deal_id;
ALTER TABLE visit_schedules ALTER COLUMN customer_id SET NOT NULL;
-- +goose StatementEnd
