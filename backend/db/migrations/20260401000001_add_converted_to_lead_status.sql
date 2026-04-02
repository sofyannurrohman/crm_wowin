-- +goose Up
-- +goose StatementBegin
ALTER TYPE lead_status ADD VALUE IF NOT EXISTS 'converted';
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
-- No rollback for enums
-- +goose StatementEnd
