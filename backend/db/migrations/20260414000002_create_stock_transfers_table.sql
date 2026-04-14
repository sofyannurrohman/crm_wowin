-- +goose Up
-- +goose StatementBegin
CREATE TYPE stock_transfer_type AS ENUM ('loading', 'unloading');
CREATE TYPE stock_transfer_status AS ENUM ('pending', 'confirmed', 'rejected');

CREATE TABLE IF NOT EXISTS stock_transfers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    warehouse_id UUID NOT NULL REFERENCES warehouses(id),
    sales_id UUID NOT NULL REFERENCES users(id),
    type stock_transfer_type NOT NULL,
    status stock_transfer_status NOT NULL DEFAULT 'pending',
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS stock_transfer_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    transfer_id UUID NOT NULL REFERENCES stock_transfers(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id),
    quantity NUMERIC(10,2) NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_stock_transfers_sales ON stock_transfers(sales_id, status);
CREATE INDEX idx_stock_transfers_warehouse ON stock_transfers(warehouse_id);
CREATE INDEX idx_stock_transfer_items_transfer ON stock_transfer_items(transfer_id);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS stock_transfer_items;
DROP TABLE IF EXISTS stock_transfers;
DROP TYPE IF EXISTS stock_transfer_status;
DROP TYPE IF EXISTS stock_transfer_type;
-- +goose StatementEnd
