-- +goose Up
-- +goose StatementBegin
ALTER TABLE visit_activities ADD COLUMN selfie_photo_path TEXT;
ALTER TABLE visit_activities ADD COLUMN place_photo_path TEXT;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
ALTER TABLE visit_activities DROP COLUMN selfie_photo_path;
ALTER TABLE visit_activities DROP COLUMN place_photo_path;
-- +goose StatementEnd
