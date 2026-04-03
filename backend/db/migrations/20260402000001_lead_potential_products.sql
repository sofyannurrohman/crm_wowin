-- Migration: Add potential_products to leads table
-- Created At: 2026-04-02
ALTER TABLE leads ADD COLUMN potential_products TEXT[];
