-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS returns (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    visit_id UUID REFERENCES visits(id) ON DELETE SET NULL,
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    sales_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    return_no VARCHAR(100) UNIQUE NOT NULL,
    total_amount NUMERIC(15,2) NOT NULL DEFAULT 0,
    reason TEXT,
    status VARCHAR(50) NOT NULL DEFAULT 'pending', -- pending, approved, rejected
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS return_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    return_id UUID NOT NULL REFERENCES returns(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id),
    name VARCHAR(255) NOT NULL,
    quantity NUMERIC(10,2) NOT NULL DEFAULT 1,
    unit VARCHAR(50) NOT NULL,
    unit_price NUMERIC(15,2) NOT NULL,
    subtotal NUMERIC(15,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_returns_customer ON returns(customer_id);
CREATE INDEX idx_returns_sales ON returns(sales_id);
CREATE INDEX idx_return_items_return ON return_items(return_id);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS return_items;
DROP TABLE IF EXISTS returns;
-- +goose StatementEnd
