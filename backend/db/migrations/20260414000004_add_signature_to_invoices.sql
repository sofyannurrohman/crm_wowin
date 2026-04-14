-- +goose Up
-- +goose StatementBegin
ALTER TABLE invoices ADD COLUMN signature_path TEXT;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
ALTER TABLE invoices DROP COLUMN IF EXISTS signature_path;
-- +goose StatementEnd
