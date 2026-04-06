-- +goose Up
-- +goose StatementBegin
DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'visits') THEN
        ALTER TABLE visits ADD COLUMN IF NOT EXISTS selfie_photo_path TEXT;
        ALTER TABLE visits ADD COLUMN IF NOT EXISTS place_photo_path TEXT;
    ELSIF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'visit_activities') THEN
        ALTER TABLE visit_activities ADD COLUMN IF NOT EXISTS selfie_photo_path TEXT;
        ALTER TABLE visit_activities ADD COLUMN IF NOT EXISTS place_photo_path TEXT;
    END IF;
END $$;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'visits') THEN
        ALTER TABLE visits DROP COLUMN IF EXISTS selfie_photo_path;
        ALTER TABLE visits DROP COLUMN IF EXISTS place_photo_path;
    ELSIF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'visit_activities') THEN
        ALTER TABLE visit_activities DROP COLUMN IF EXISTS selfie_photo_path;
        ALTER TABLE visit_activities DROP COLUMN IF EXISTS place_photo_path;
    END IF;
END $$;
-- +goose StatementEnd
