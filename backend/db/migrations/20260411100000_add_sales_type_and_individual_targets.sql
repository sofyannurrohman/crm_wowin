-- +goose Up
-- +goose StatementBegin
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'sales_type') THEN
        CREATE TYPE sales_type AS ENUM ('motoris', 'task_order', 'canvas');
    END IF;
END
$$;
-- +goose StatementEnd

ALTER TABLE users ADD COLUMN IF NOT EXISTS sales_type sales_type;

CREATE TABLE IF NOT EXISTS sales_targets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    period_year SMALLINT NOT NULL,
    period_month SMALLINT NOT NULL CHECK (period_month BETWEEN 1 AND 12),
    target_revenue NUMERIC(15,2) DEFAULT 0,
    target_visits INT DEFAULT 0,
    target_deals INT DEFAULT 0,
    target_new_customers INT DEFAULT 0,
    win_rate FLOAT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, period_year, period_month)
);

-- +goose Down
DROP TABLE IF EXISTS sales_targets;
ALTER TABLE users DROP COLUMN IF EXISTS sales_type;
-- +goose StatementBegin
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_type WHERE typname = 'sales_type') THEN
        DROP TYPE sales_type;
    END IF;
END
$$;
-- +goose StatementEnd
