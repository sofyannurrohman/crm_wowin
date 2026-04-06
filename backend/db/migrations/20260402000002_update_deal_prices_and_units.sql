-- Migration: Update products and deal_items for PT Wowin Kecap pricing
-- Added prices per unit and unit support to deal items

-- +goose Up
-- +goose StatementBegin
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS price_pcs NUMERIC(15,2) NOT NULL DEFAULT 0,
ADD COLUMN IF NOT EXISTS price_dus NUMERIC(15,2) NOT NULL DEFAULT 0,
ADD COLUMN IF NOT EXISTS price_crate NUMERIC(15,2) NOT NULL DEFAULT 0;

DO $$
BEGIN
    -- Update existing products to have base_price or price as price_pcs
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'products' AND column_name = 'base_price') THEN
        UPDATE products SET price_pcs = base_price;
    ELSIF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'products' AND column_name = 'price') THEN
        UPDATE products SET price_pcs = price;
    END IF;
END $$;
-- +goose StatementEnd

ALTER TABLE deal_items 
ADD COLUMN unit VARCHAR(50) NOT NULL DEFAULT 'pcs';

-- +goose Down
ALTER TABLE deal_items DROP COLUMN IF EXISTS unit;
ALTER TABLE products DROP COLUMN IF EXISTS price_pcs;
ALTER TABLE products DROP COLUMN IF EXISTS price_dus;
ALTER TABLE products DROP COLUMN IF EXISTS price_crate;
