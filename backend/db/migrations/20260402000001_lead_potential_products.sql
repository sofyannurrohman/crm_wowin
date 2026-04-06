-- Migration: Add potential_products to leads table
-- Created At: 2026-04-02

-- +goose Up
ALTER TABLE leads ADD COLUMN potential_products TEXT[];

-- +goose Down
ALTER TABLE leads DROP COLUMN IF EXISTS potential_products;
