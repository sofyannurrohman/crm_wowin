-- Migration: Add Lead Visitation Support
-- Date: 2026-04-07

-- 1. Update visit_schedules
ALTER TABLE visit_schedules ADD COLUMN lead_id UUID REFERENCES leads(id) ON DELETE SET NULL;
ALTER TABLE visit_schedules ALTER COLUMN customer_id DROP NOT NULL;

-- 2. Update visits
ALTER TABLE visits ADD COLUMN lead_id UUID REFERENCES leads(id) ON DELETE SET NULL;
ALTER TABLE visits ALTER COLUMN customer_id DROP NOT NULL;

-- 3. Update activities (Sales Activity)
-- Note: activities table was previously defined as having customer_id, contact_id, deal_id, visit_id.
-- If this refers to the 'activities' table in schema.sql, let's add lead_id.
ALTER TABLE activities ADD COLUMN lead_id UUID REFERENCES leads(id) ON DELETE SET NULL;
ALTER TABLE activities ALTER COLUMN customer_id DROP NOT NULL;

-- 4. Update sales_activities (The backend model uses this table name in newer migrations)
DO $$ 
BEGIN
    IF EXISTS (SELECT FROM pg_tables WHERE tablename = 'sales_activities') THEN
        IF NOT EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'sales_activities' AND column_name = 'lead_id') THEN
            ALTER TABLE sales_activities ADD COLUMN lead_id UUID REFERENCES leads(id) ON DELETE SET NULL;
        END IF;
        ALTER TABLE sales_activities ALTER COLUMN customer_id DROP NOT NULL;
    END IF;
END $$;
