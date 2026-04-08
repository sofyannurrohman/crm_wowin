-- Add address column to leads table

-- +goose Up
ALTER TABLE leads
ADD COLUMN IF NOT EXISTS address TEXT;

-- +goose Down
ALTER TABLE leads
DROP COLUMN IF EXISTS address;
