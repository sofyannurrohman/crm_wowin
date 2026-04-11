-- +goose Up
-- +goose StatementBegin
-- 1. Add signature_path to sales_activities
ALTER TABLE sales_activities ADD COLUMN signature_path TEXT;

-- 2. Create van_stocks table
CREATE TABLE IF NOT EXISTS van_stocks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    quantity DECIMAL(15, 2) NOT NULL DEFAULT 0,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, product_id)
);

CREATE INDEX idx_van_stock_user ON van_stocks(user_id);

-- 3. Create payments table
CREATE TABLE IF NOT EXISTS payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    activity_id UUID NOT NULL REFERENCES sales_activities(id) ON DELETE CASCADE,
    amount DECIMAL(15, 2) NOT NULL,
    method VARCHAR(50) NOT NULL, -- cash, transfer, credit
    reference_no VARCHAR(100),
    photo_path TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_payments_activity ON payments(activity_id);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS van_stocks;
ALTER TABLE sales_activities DROP COLUMN IF EXISTS signature_path;
-- +goose StatementEnd
