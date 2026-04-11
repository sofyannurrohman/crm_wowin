-- +goose Up
-- +goose StatementBegin
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'customer_type') THEN
        CREATE TYPE customer_type AS ENUM ('individual', 'company');
    END IF;
END
$$;
-- +goose StatementEnd

-- +goose Down
-- No-op: dropping enums is risky
