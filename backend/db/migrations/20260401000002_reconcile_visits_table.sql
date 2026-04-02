-- +goose Up
-- +goose StatementBegin
DO $$
BEGIN
    -- 1. Check if the old visit_activities table exists
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'visit_activities') 
       AND NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'visits') THEN
        
        -- Rename the table to match the current backend expectations
        ALTER TABLE visit_activities RENAME TO visits;
        
        -- 2. Rename existing columns to match the new schema
        -- Mapping: location -> checkin_location, notes -> result_notes, distance -> checkin_distance
        ALTER TABLE visits RENAME COLUMN location TO checkin_location;
        ALTER TABLE visits RENAME COLUMN notes TO result_notes;
        ALTER TABLE visits RENAME COLUMN distance TO checkin_distance;
        ALTER TABLE visits RENAME COLUMN created_at TO checkin_at;
        
        -- 3. Add missing columns required by the new visit logic
        ALTER TABLE visits ADD COLUMN IF NOT EXISTS status VARCHAR(50) NOT NULL DEFAULT 'completed';
        ALTER TABLE visits ADD COLUMN IF NOT EXISTS deal_id UUID REFERENCES deals(id) ON DELETE SET NULL;
        ALTER TABLE visits ADD COLUMN IF NOT EXISTS checkout_at TIMESTAMP WITH TIME ZONE;
        ALTER TABLE visits ADD COLUMN IF NOT EXISTS checkout_location GEOMETRY(POINT, 4326);
        ALTER TABLE visits ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        ALTER TABLE visits ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

        -- 4. Re-populate the new created_at from checkin_at for consistency
        UPDATE visits SET created_at = checkin_at;

        -- 5. Fix status based on activity type if migrations were mixed
        UPDATE visits SET status = 'in_progress' WHERE checkout_at IS NULL;
        
        -- Remove the 'type' column as the new schema uses checkin/checkout timestamps
        ALTER TABLE visits DROP COLUMN IF EXISTS type;
        ALTER TABLE visits DROP COLUMN IF EXISTS is_offline;
    
    ELSIF NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'visits') THEN
        -- Fallback: Create from scratch if neither exists (should be handled by initial_schema, but safer)
        CREATE TABLE visits (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            schedule_id UUID REFERENCES visit_schedules(id) ON DELETE SET NULL,
            sales_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
            customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
            deal_id UUID REFERENCES deals(id) ON DELETE SET NULL,
            status VARCHAR(50) NOT NULL DEFAULT 'in_progress',
            checkin_at TIMESTAMP WITH TIME ZONE,
            checkin_location GEOMETRY(POINT, 4326),
            checkin_distance DECIMAL(10, 2),
            checkout_at TIMESTAMP WITH TIME ZONE,
            checkout_location GEOMETRY(POINT, 4326),
            result_notes TEXT,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
    END IF;
END $$;
-- +goose StatementEnd

-- +goose Down
-- Simple cleanup for reversal if needed (though renames are risky to undo)
-- +goose StatementBegin
-- We don't drop 'visits' here as it might contain valid production data renamed from 'activities'
-- +goose StatementEnd
