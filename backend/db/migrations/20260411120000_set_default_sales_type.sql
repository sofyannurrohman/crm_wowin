-- +goose Up
UPDATE users SET sales_type = 'motoris' WHERE sales_type IS NULL;

-- +goose Down
-- No reversal needed for data migration
