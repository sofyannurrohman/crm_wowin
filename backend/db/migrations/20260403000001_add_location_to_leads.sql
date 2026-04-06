-- Add location fields to leads table

-- +goose Up
ALTER TABLE leads 
ADD COLUMN latitude DOUBLE PRECISION,
ADD COLUMN longitude DOUBLE PRECISION;

-- +goose Down
ALTER TABLE leads 
DROP COLUMN latitude,
DROP COLUMN longitude;
