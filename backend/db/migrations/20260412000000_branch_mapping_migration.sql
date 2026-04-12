-- +goose Up
-- +goose StatementBegin

-- 1. Add warehouse_id to territories
ALTER TABLE territories ADD COLUMN warehouse_id UUID REFERENCES warehouses(id) ON DELETE SET NULL;

-- 2. Add warehouse_id to users
ALTER TABLE users ADD COLUMN warehouse_id UUID REFERENCES warehouses(id) ON DELETE SET NULL;

-- 3. Seed initial branches (Warehouses)
-- Surakarta (Solo): -7.5666, 110.8167
-- Yogyakarta: -7.7956, 110.3695
-- Trenggalek: -8.0500, 111.7167

INSERT INTO warehouses (id, name, address, latitude, longitude) VALUES 
(uuid_generate_v4(), 'Cabang Surakarta', 'Jl. Slamet Riyadi, Surakarta', -7.5666, 110.8167),
(uuid_generate_v4(), 'Cabang Yogyakarta', 'Jl. Malioboro, Yogyakarta', -7.7956, 110.3695),
(uuid_generate_v4(), 'Cabang Trenggalek', 'Jl. Pemuda, Trenggalek', -8.0500, 111.7167);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
ALTER TABLE users DROP COLUMN warehouse_id;
ALTER TABLE territories DROP COLUMN warehouse_id;
DELETE FROM warehouses WHERE name IN ('Cabang Surakarta', 'Cabang Yogyakarta', 'Cabang Trenggalek');
-- +goose StatementEnd
