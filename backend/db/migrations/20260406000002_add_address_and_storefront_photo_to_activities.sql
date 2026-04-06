-- +goose Up
-- +goose StatementBegin
ALTER TABLE sales_activities
ADD COLUMN address TEXT,
ADD COLUMN storefront_photo_base64 TEXT;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
ALTER TABLE sales_activities
DROP COLUMN address,
DROP COLUMN storefront_photo_base64;
-- +goose StatementEnd
