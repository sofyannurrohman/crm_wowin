-- Add technical visit fields to sales_activities to allow unification
-- +goose Up
ALTER TABLE sales_activities 
ADD COLUMN IF NOT EXISTS check_in_time TIMESTAMP,
ADD COLUMN IF NOT EXISTS check_out_time TIMESTAMP,
ADD COLUMN IF NOT EXISTS selfie_photo_path TEXT,
ADD COLUMN IF NOT EXISTS place_photo_path TEXT,
ADD COLUMN IF NOT EXISTS distance DOUBLE PRECISION,
ADD COLUMN IF NOT EXISTS is_offline BOOLEAN DEFAULT FALSE;

-- +goose Down
ALTER TABLE sales_activities 
DROP COLUMN IF EXISTS check_in_time,
DROP COLUMN IF EXISTS check_out_time,
DROP COLUMN IF EXISTS selfie_photo_path,
DROP COLUMN IF EXISTS place_photo_path,
DROP COLUMN IF EXISTS distance,
DROP COLUMN IF EXISTS is_offline;
