-- +goose Up
-- +goose StatementBegin
CREATE TABLE IF NOT EXISTS app_settings (
    key VARCHAR(100) PRIMARY KEY,
    value JSONB NOT NULL,
    description TEXT,
    updated_by UUID, -- No FK to users for now to avoid dependency issues during hotfix
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Seed defaults on conflict do nothing
INSERT INTO app_settings (key, value, description) VALUES
('visit.checkin_radius_default', '100', 'Default radius check-in (meter)'),
('tracking.interval_seconds', '30', 'Interval kirim GPS saat bergerak (detik)'),
('tracking.idle_interval_seconds', '120', 'Interval kirim GPS saat diam (detik)'),
('tracking.work_start_hour', '7', 'Jam mulai tracking otomatis (WIB)'),
('tracking.work_end_hour', '18', 'Jam selesai tracking otomatis (WIB)'),
('photo.max_size_kb', '5120', 'Ukuran maksimum foto kunjungan (KB)'),
('photo.allowed_types', '["image/jpeg","image/png","image/webp"]', 'Tipe file foto yang diizinkan'),
('storage.upload_base_path', '"/app/uploads"', 'Root folder penyimpanan file di VPS (diakses Gin)'),
('storage.visit_photos_path', '"visits/{YYYY}/{MM}/{DD}/{visit_id}"', 'Pola subfolder foto kunjungan'),
('storage.attendance_photos_path', '"attendance/{YYYY}/{MM}"', 'Subfolder foto absensi'),
('storage.base_url', '"http://localhost:8082/uploads"', 'Base URL static file server Gin (/uploads route)')
ON CONFLICT (key) DO NOTHING;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
-- Keep the table in down migration to avoid accidental data loss since this is a recovery fix
-- +goose StatementEnd
