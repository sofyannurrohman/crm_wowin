-- Add visit tracking fields to sales_activities table

-- +goose Up
ALTER TABLE sales_activities 
ADD COLUMN check_in_time TIMESTAMP,
ADD COLUMN check_out_time TIMESTAMP,
ADD COLUMN photo_base64 TEXT,
ADD COLUMN outcome TEXT;

-- +goose Down
ALTER TABLE sales_activities 
DROP COLUMN check_in_time,
DROP COLUMN check_out_time,
DROP COLUMN photo_base64,
DROP COLUMN outcome;
