-- +goose Up
CREATE TABLE IF NOT EXISTS global_targets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    monthly_revenue BIGINT NOT NULL DEFAULT 500000000,
    monthly_visits INT NOT NULL DEFAULT 150,
    monthly_new_customers INT NOT NULL DEFAULT 20,
    win_rate FLOAT NOT NULL DEFAULT 30,
    monthly_deals INT NOT NULL DEFAULT 10,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Seed initial target
INSERT INTO global_targets (monthly_revenue, monthly_visits, monthly_new_customers, win_rate, monthly_deals)
VALUES (500000000, 150, 20, 30, 10);

-- +goose Down
DROP TABLE IF EXISTS global_targets;
