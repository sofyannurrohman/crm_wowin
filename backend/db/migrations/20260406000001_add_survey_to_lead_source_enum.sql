-- +goose Up
-- +goose StatementBegin
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_type WHERE typname = 'lead_source') THEN
        ALTER TYPE lead_source ADD VALUE IF NOT EXISTS 'survey';
    END IF;
END $$;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
-- Removing enum values is not directly supported in Postgres ALTER TYPE.
-- +goose StatementEnd
