-- Migration: Update products and deal_items for PT Wowin Kecap pricing
-- Added prices per unit and unit support to deal items

ALTER TABLE products 
ADD COLUMN price_pcs NUMERIC(15,2) NOT NULL DEFAULT 0,
ADD COLUMN price_dus NUMERIC(15,2) NOT NULL DEFAULT 0,
ADD COLUMN price_crate NUMERIC(15,2) NOT NULL DEFAULT 0;

-- Update existing products to have base_price as price_pcs (optional)
UPDATE products SET price_pcs = base_price;

ALTER TABLE deal_items 
ADD COLUMN unit VARCHAR(50) NOT NULL DEFAULT 'pcs';
