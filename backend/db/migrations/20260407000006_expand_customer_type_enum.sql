-- +goose Up
-- +goose StatementBegin
ALTER TYPE customer_type ADD VALUE 'warung';
ALTER TYPE customer_type ADD VALUE 'retail';
ALTER TYPE customer_type ADD VALUE 'toko';
ALTER TYPE customer_type ADD VALUE 'agen';
ALTER TYPE customer_type ADD VALUE 'restoran';
ALTER TYPE customer_type ADD VALUE 'cafe';
ALTER TYPE customer_type ADD VALUE 'lainnya';
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
-- Note: PostgreSQL does not support dropping enum values easily. 
-- Usually requires recreating the type, which is risky for existing data.
-- +goose StatementEnd
