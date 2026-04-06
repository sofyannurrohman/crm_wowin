-- +goose Up
-- +goose StatementBegin
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_type WHERE typname = 'lead_status') THEN
        ALTER TYPE lead_status ADD VALUE IF NOT EXISTS 'converted';
    END IF;
END $$;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
-- No rollback for enums
-- +goose StatementEnd
