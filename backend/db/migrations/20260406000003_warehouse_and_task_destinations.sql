-- +goose Up
-- +goose StatementBegin
CREATE TABLE warehouses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    address TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Seed Gudang PT Wowin Purnomo Putera (contoh koordinat Jakarta/Bekasi jika ada, kita pakai default Monas dulu = -6.1754, 106.8272)
INSERT INTO warehouses (name, address, latitude, longitude) VALUES ('Gudang Utama PT Wowin Purnomo Putera', 'Jl. Kawasan Industri', -6.1754, 106.8272);

ALTER TABLE tasks DROP COLUMN customer_id;

CREATE TABLE task_destinations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    lead_id UUID REFERENCES leads(id) ON DELETE SET NULL,
    customer_id UUID REFERENCES customers(id) ON DELETE SET NULL,
    sequence_order INT NOT NULL DEFAULT 0,
    status VARCHAR(50) NOT NULL DEFAULT 'TODO',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE sales_activities ADD COLUMN task_destination_id UUID REFERENCES task_destinations(id) ON DELETE SET NULL;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
ALTER TABLE sales_activities DROP COLUMN task_destination_id;
DROP TABLE task_destinations;
ALTER TABLE tasks ADD COLUMN customer_id UUID REFERENCES customers(id) ON DELETE SET NULL;
DROP TABLE warehouses;
-- +goose StatementEnd
