-- ============================================================
-- CRM & SALES FIELD MANAGEMENT SYSTEM
-- PostgreSQL + PostGIS Database Schema
-- Versi: 1.1 | 12 Maret 2026
-- Storage: VPS Lokal (Nginx file server) — tanpa S3/MinIO
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- ============================================================
-- ENUM TYPES
-- ============================================================

CREATE TYPE user_role AS ENUM ('super_admin', 'manager', 'supervisor', 'sales');
CREATE TYPE user_status AS ENUM ('active', 'inactive', 'suspended');

CREATE TYPE customer_type AS ENUM ('individual', 'company');
CREATE TYPE customer_status AS ENUM ('prospect', 'active', 'inactive', 'churned');

CREATE TYPE lead_status AS ENUM ('new', 'contacted', 'qualified', 'unqualified', 'converted');
CREATE TYPE lead_source AS ENUM ('referral', 'cold_call', 'social_media', 'website', 'event', 'other');

CREATE TYPE deal_stage AS ENUM ('prospecting', 'qualification', 'proposal', 'negotiation', 'closed_won', 'closed_lost');
CREATE TYPE deal_status AS ENUM ('open', 'won', 'lost');

CREATE TYPE visit_status AS ENUM ('scheduled', 'in_progress', 'completed', 'skipped', 'cancelled');
CREATE TYPE sales_tracking_status AS ENUM ('on_the_way', 'at_location', 'idle', 'offline');

CREATE TYPE task_status AS ENUM ('pending', 'in_progress', 'done', 'cancelled');
CREATE TYPE task_priority AS ENUM ('low', 'medium', 'high', 'urgent');

CREATE TYPE notification_type AS ENUM ('visit_reminder', 'follow_up', 'deal_update', 'approval', 'broadcast', 'system');
CREATE TYPE attendance_type AS ENUM ('clock_in', 'clock_out');
CREATE TYPE territory_status AS ENUM ('active', 'inactive');

-- ============================================================
-- 1. USERS & AUTH
-- ============================================================

CREATE TABLE users (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name            VARCHAR(150) NOT NULL,
    email           VARCHAR(255) NOT NULL UNIQUE,
    phone           VARCHAR(20),
    password_hash   TEXT NOT NULL,
    role            user_role NOT NULL DEFAULT 'sales',
    status          user_status NOT NULL DEFAULT 'active',
    -- Avatar disimpan lokal: /uploads/avatars/{user_id}.jpg
    avatar_path     TEXT,                           -- path relatif di VPS
    manager_id      UUID REFERENCES users(id) ON DELETE SET NULL,
    employee_code   VARCHAR(50) UNIQUE,
    joined_at       DATE,
    last_login_at   TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_users_role    ON users(role);
CREATE INDEX idx_users_manager ON users(manager_id);
CREATE INDEX idx_users_status  ON users(status);

-- ----
CREATE TABLE refresh_tokens (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash  TEXT NOT NULL UNIQUE,
    expires_at  TIMESTAMPTZ NOT NULL,
    revoked     BOOLEAN NOT NULL DEFAULT FALSE,
    ip_address  INET,
    user_agent  TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_refresh_tokens_user ON refresh_tokens(user_id);
CREATE INDEX idx_refresh_tokens_hash ON refresh_tokens(token_hash);

-- ----
CREATE TABLE audit_logs (
    id          BIGSERIAL PRIMARY KEY,
    user_id     UUID REFERENCES users(id) ON DELETE SET NULL,
    action      VARCHAR(100) NOT NULL,              -- e.g. 'customer.update'
    entity_type VARCHAR(100),
    entity_id   UUID,
    old_data    JSONB,
    new_data    JSONB,
    ip_address  INET,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_user    ON audit_logs(user_id);
CREATE INDEX idx_audit_entity  ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_created ON audit_logs(created_at);

-- ============================================================
-- 2. TERRITORY / AREA KERJA
-- ============================================================

CREATE TABLE territories (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name        VARCHAR(150) NOT NULL,
    description TEXT,
    geom        GEOMETRY(MULTIPOLYGON, 4326),       -- polygon area di peta
    color       VARCHAR(7) DEFAULT '#3B82F6',
    status      territory_status NOT NULL DEFAULT 'active',
    created_by  UUID REFERENCES users(id),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_territories_geom ON territories USING GIST(geom);

CREATE TABLE territory_users (
    territory_id UUID NOT NULL REFERENCES territories(id) ON DELETE CASCADE,
    user_id      UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    assigned_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    assigned_by  UUID REFERENCES users(id),
    PRIMARY KEY (territory_id, user_id)
);

-- ============================================================
-- 3. CUSTOMERS (PELANGGAN)
-- ============================================================

CREATE TABLE customers (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code            VARCHAR(50) UNIQUE,
    type            customer_type NOT NULL DEFAULT 'company',
    name            VARCHAR(255) NOT NULL,
    company_name    VARCHAR(255),
    industry        VARCHAR(100),
    website         VARCHAR(255),
    email           VARCHAR(255),
    phone           VARCHAR(30),
    phone_alt       VARCHAR(30),
    status          customer_status NOT NULL DEFAULT 'prospect',

    -- Alamat
    address         TEXT,
    city            VARCHAR(100),
    province        VARCHAR(100),
    postal_code     VARCHAR(10),
    country         VARCHAR(100) DEFAULT 'Indonesia',

    -- Koordinat lokasi pelanggan (PostGIS point)
    -- Digunakan untuk: validasi radius check-in, peta, territory auto-assign
    location        GEOMETRY(POINT, 4326),
    checkin_radius  INT NOT NULL DEFAULT 100,       -- meter, bisa override per pelanggan

    -- Relasi
    territory_id    UUID REFERENCES territories(id) ON DELETE SET NULL,
    assigned_to     UUID REFERENCES users(id) ON DELETE SET NULL,
    created_by      UUID REFERENCES users(id),

    -- Finansial
    credit_limit    NUMERIC(15,2),
    payment_terms   INT DEFAULT 30,                 -- hari

    notes           TEXT,
    tags            TEXT[],
    meta            JSONB,

    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ                     -- soft delete
);

CREATE INDEX idx_customers_status    ON customers(status);
CREATE INDEX idx_customers_assigned  ON customers(assigned_to);
CREATE INDEX idx_customers_territory ON customers(territory_id);
CREATE INDEX idx_customers_location  ON customers USING GIST(location);
CREATE INDEX idx_customers_name_trgm ON customers USING GIN(name gin_trgm_ops);
CREATE INDEX idx_customers_active    ON customers(id) WHERE deleted_at IS NULL;

-- ----
CREATE TABLE contacts (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    name        VARCHAR(150) NOT NULL,
    title       VARCHAR(100),
    department  VARCHAR(100),
    email       VARCHAR(255),
    phone       VARCHAR(30),
    phone_alt   VARCHAR(30),
    is_primary  BOOLEAN NOT NULL DEFAULT FALSE,
    notes       TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_contacts_customer ON contacts(customer_id);

-- ============================================================
-- 4. LEADS
-- ============================================================

CREATE TABLE leads (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title           VARCHAR(255) NOT NULL,
    name            VARCHAR(150) NOT NULL,
    company         VARCHAR(255),
    email           VARCHAR(255),
    phone           VARCHAR(30),
    source          lead_source NOT NULL DEFAULT 'other',
    status          lead_status NOT NULL DEFAULT 'new',
    assigned_to     UUID REFERENCES users(id) ON DELETE SET NULL,
    customer_id     UUID REFERENCES customers(id) ON DELETE SET NULL,
    estimated_value NUMERIC(15,2),
    potential_products TEXT[],
    notes           TEXT,
    converted_at    TIMESTAMPTZ,
    created_by      UUID REFERENCES users(id),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_leads_status   ON leads(status);
CREATE INDEX idx_leads_assigned ON leads(assigned_to);

-- ============================================================
-- 5. DEALS (PELUANG PENJUALAN)
-- ============================================================

CREATE TABLE deals (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title           VARCHAR(255) NOT NULL,
    customer_id     UUID NOT NULL REFERENCES customers(id),
    contact_id      UUID REFERENCES contacts(id),
    assigned_to     UUID REFERENCES users(id) ON DELETE SET NULL,
    stage           deal_stage NOT NULL DEFAULT 'prospecting',
    status          deal_status NOT NULL DEFAULT 'open',
    amount          NUMERIC(15,2),
    probability     SMALLINT DEFAULT 0 CHECK (probability BETWEEN 0 AND 100),
    expected_close  DATE,
    closed_at       TIMESTAMPTZ,
    lost_reason     TEXT,
    description     TEXT,
    created_by      UUID REFERENCES users(id),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_deals_customer ON deals(customer_id);
CREATE INDEX idx_deals_assigned ON deals(assigned_to);
CREATE INDEX idx_deals_stage    ON deals(stage);
CREATE INDEX idx_deals_status   ON deals(status);

CREATE TABLE deal_stage_history (
    id          BIGSERIAL PRIMARY KEY,
    deal_id     UUID NOT NULL REFERENCES deals(id) ON DELETE CASCADE,
    from_stage  deal_stage,
    to_stage    deal_stage NOT NULL,
    changed_by  UUID REFERENCES users(id),
    notes       TEXT,
    changed_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_deal_stage_hist ON deal_stage_history(deal_id);

-- ============================================================
-- 6. PRODUK & KATALOG
-- ============================================================

CREATE TABLE product_categories (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name        VARCHAR(150) NOT NULL,
    parent_id   UUID REFERENCES product_categories(id),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE products (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code        VARCHAR(100) UNIQUE,
    name        VARCHAR(255) NOT NULL,
    category_id UUID REFERENCES product_categories(id),
    description TEXT,
    unit        VARCHAR(50),                        -- Global default unit
    base_price  NUMERIC(15,2) NOT NULL DEFAULT 0,
    is_active   BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE deal_items (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    deal_id     UUID NOT NULL REFERENCES deals(id) ON DELETE CASCADE,
    product_id  UUID REFERENCES products(id),
    name        VARCHAR(255) NOT NULL,
    quantity    NUMERIC(10,2) NOT NULL DEFAULT 1,
    unit        VARCHAR(50) NOT NULL,               -- pcs, dus, crate
    unit_price  NUMERIC(15,2) NOT NULL,
    discount    NUMERIC(5,2) DEFAULT 0,             -- persen
    subtotal    NUMERIC(15,2) GENERATED ALWAYS AS
                    (quantity * unit_price * (1 - discount/100)) STORED,
    notes       TEXT
);

CREATE INDEX idx_deal_items_deal ON deal_items(deal_id);

-- ============================================================
-- 7. KUNJUNGAN SALES (VISITS) ⭐
-- ============================================================

CREATE TABLE visit_schedules (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sales_id        UUID NOT NULL REFERENCES users(id),
    customer_id     UUID NOT NULL REFERENCES customers(id),
    scheduled_date  DATE NOT NULL,
    scheduled_time  TIME,
    visit_order     SMALLINT DEFAULT 1,             -- urutan kunjungan hari itu
    notes           TEXT,
    created_by      UUID REFERENCES users(id),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_visit_sch_sales    ON visit_schedules(sales_id, scheduled_date);
CREATE INDEX idx_visit_sch_customer ON visit_schedules(customer_id);

-- ----
CREATE TABLE visits (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    schedule_id         UUID REFERENCES visit_schedules(id) ON DELETE SET NULL,
    sales_id            UUID NOT NULL REFERENCES users(id),
    customer_id         UUID NOT NULL REFERENCES customers(id),
    deal_id             UUID REFERENCES deals(id),
    status              visit_status NOT NULL DEFAULT 'in_progress',

    -- Check-in (wajib foto)
    checkin_at          TIMESTAMPTZ,
    checkin_location    GEOMETRY(POINT, 4326),
    checkin_address     TEXT,                       -- hasil reverse geocode
    checkin_distance    FLOAT,                      -- meter dari titik pelanggan
    checkin_is_valid    BOOLEAN,                    -- TRUE jika dalam radius

    -- Check-out
    checkout_at         TIMESTAMPTZ,
    checkout_location   GEOMETRY(POINT, 4326),

    -- Durasi otomatis terhitung
    duration_minutes    INT GENERATED ALWAYS AS (
                            EXTRACT(EPOCH FROM (checkout_at - checkin_at)) / 60
                        )::INT STORED,

    -- Laporan singkat saat check-out
    result_notes        TEXT,
    next_action         TEXT,
    next_visit_date     DATE,
    skip_reason         TEXT,

    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_visits_sales       ON visits(sales_id);
CREATE INDEX idx_visits_customer    ON visits(customer_id);
CREATE INDEX idx_visits_date        ON visits(checkin_at);
CREATE INDEX idx_visits_status      ON visits(status);
CREATE INDEX idx_visits_location    ON visits USING GIST(checkin_location);

-- ============================================================
-- FOTO KUNJUNGAN — Disimpan Lokal di VPS
-- Struktur folder: /var/www/uploads/visits/{YYYY}/{MM}/{DD}/{visit_id}/
-- URL via Nginx: https://domain.com/uploads/visits/...
-- ============================================================

CREATE TABLE visit_photos (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    visit_id            UUID NOT NULL REFERENCES visits(id) ON DELETE CASCADE,

    -- Path & akses file lokal VPS
    -- Contoh: visits/2026/03/12/abc-uuid/checkin_01.jpg
    file_path           TEXT NOT NULL,              -- path relatif dari /var/www/uploads/
    file_name           TEXT NOT NULL,              -- nama file asli setelah rename
    mime_type           VARCHAR(50) NOT NULL        -- wajib: image/jpeg atau image/png
                            CHECK (mime_type IN ('image/jpeg','image/png','image/webp')),
    file_size_kb        INT NOT NULL,               -- ukuran file dalam KB
    width               INT,                        -- pixel width
    height              INT,                        -- pixel height

    -- Metadata teknis
    taken_at            TIMESTAMPTZ NOT NULL,       -- timestamp dari device
    location            GEOMETRY(POINT, 4326),      -- GPS saat foto diambil
    checksum            TEXT,                       -- SHA256, untuk deteksi manipulasi
    device_info         JSONB,                      -- info kamera/device (opsional)

    -- Flag jenis foto
    is_checkin_photo    BOOLEAN NOT NULL DEFAULT FALSE,  -- foto wajib saat check-in
    is_checkout_photo   BOOLEAN NOT NULL DEFAULT FALSE,  -- foto tambahan saat check-out

    uploaded_at         TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_visit_photos_visit ON visit_photos(visit_id);
CREATE INDEX idx_visit_photos_loc   ON visit_photos USING GIST(location);

-- ============================================================
-- 8. GPS TRACKING ⭐
-- ============================================================

-- Satu baris per hari per sales
CREATE TABLE tracking_sessions (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sales_id        UUID NOT NULL REFERENCES users(id),
    session_date    DATE NOT NULL,
    started_at      TIMESTAMPTZ,
    ended_at        TIMESTAMPTZ,
    status          sales_tracking_status NOT NULL DEFAULT 'offline',
    total_distance  FLOAT DEFAULT 0,                -- meter
    route           GEOMETRY(LINESTRING, 4326),     -- polyline rute hari itu
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(sales_id, session_date)
);

CREATE INDEX idx_tracking_sessions_sales  ON tracking_sessions(sales_id);
CREATE INDEX idx_tracking_sessions_date   ON tracking_sessions(session_date);
CREATE INDEX idx_tracking_sessions_route  ON tracking_sessions USING GIST(route);

-- Titik GPS individual — volume tinggi, dipartisi per bulan
CREATE TABLE gps_points (
    id              BIGSERIAL,
    session_id      UUID NOT NULL REFERENCES tracking_sessions(id) ON DELETE CASCADE,
    sales_id        UUID NOT NULL REFERENCES users(id),
    recorded_at     TIMESTAMPTZ NOT NULL,
    location        GEOMETRY(POINT, 4326) NOT NULL,
    accuracy        FLOAT,                          -- akurasi GPS dalam meter
    speed           FLOAT,                          -- kecepatan m/s
    heading         FLOAT,                          -- arah 0-360 derajat
    altitude        FLOAT,
    battery_level   SMALLINT,                       -- persen baterai device
    PRIMARY KEY (id, recorded_at)
) PARTITION BY RANGE (recorded_at);

-- Partisi per bulan 2026
CREATE TABLE gps_points_2026_01 PARTITION OF gps_points FOR VALUES FROM ('2026-01-01') TO ('2026-02-01');
CREATE TABLE gps_points_2026_02 PARTITION OF gps_points FOR VALUES FROM ('2026-02-01') TO ('2026-03-01');
CREATE TABLE gps_points_2026_03 PARTITION OF gps_points FOR VALUES FROM ('2026-03-01') TO ('2026-04-01');
CREATE TABLE gps_points_2026_04 PARTITION OF gps_points FOR VALUES FROM ('2026-04-01') TO ('2026-05-01');
CREATE TABLE gps_points_2026_05 PARTITION OF gps_points FOR VALUES FROM ('2026-05-01') TO ('2026-06-01');
CREATE TABLE gps_points_2026_06 PARTITION OF gps_points FOR VALUES FROM ('2026-06-01') TO ('2026-07-01');
CREATE TABLE gps_points_2026_07 PARTITION OF gps_points FOR VALUES FROM ('2026-07-01') TO ('2026-08-01');
CREATE TABLE gps_points_2026_08 PARTITION OF gps_points FOR VALUES FROM ('2026-08-01') TO ('2026-09-01');
CREATE TABLE gps_points_2026_09 PARTITION OF gps_points FOR VALUES FROM ('2026-09-01') TO ('2026-10-01');
CREATE TABLE gps_points_2026_10 PARTITION OF gps_points FOR VALUES FROM ('2026-10-01') TO ('2026-11-01');
CREATE TABLE gps_points_2026_11 PARTITION OF gps_points FOR VALUES FROM ('2026-11-01') TO ('2026-12-01');
CREATE TABLE gps_points_2026_12 PARTITION OF gps_points FOR VALUES FROM ('2026-12-01') TO ('2027-01-01');

CREATE INDEX idx_gps_session  ON gps_points(session_id, recorded_at);
CREATE INDEX idx_gps_sales    ON gps_points(sales_id, recorded_at);
CREATE INDEX idx_gps_location ON gps_points USING GIST(location);

-- Posisi terakhir per sales — untuk real-time map di dashboard
CREATE TABLE sales_live_positions (
    sales_id        UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    location        GEOMETRY(POINT, 4326) NOT NULL,
    status          sales_tracking_status NOT NULL DEFAULT 'offline',
    speed           FLOAT,
    heading         FLOAT,
    battery_level   SMALLINT,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_live_positions_loc    ON sales_live_positions USING GIST(location);
CREATE INDEX idx_live_positions_status ON sales_live_positions(status);

-- ============================================================
-- 9. ABSENSI
-- ============================================================

CREATE TABLE attendances (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL REFERENCES users(id),
    type            attendance_type NOT NULL,
    location        GEOMETRY(POINT, 4326),
    address         TEXT,
    -- Foto absen disimpan lokal: /var/www/uploads/attendance/{YYYY}/{MM}/
    photo_path      TEXT,                           -- path relatif di VPS
    device_info     JSONB,
    timestamp_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    notes           TEXT
);

CREATE INDEX idx_attendance_user ON attendances(user_id);
CREATE INDEX idx_attendance_date ON attendances(timestamp_at);

CREATE VIEW daily_attendance AS
SELECT
    user_id,
    DATE(timestamp_at)                                              AS work_date,
    MIN(timestamp_at) FILTER (WHERE type = 'clock_in')             AS clock_in,
    MAX(timestamp_at) FILTER (WHERE type = 'clock_out')            AS clock_out,
    ROUND(
        EXTRACT(EPOCH FROM (
            MAX(timestamp_at) FILTER (WHERE type = 'clock_out') -
            MIN(timestamp_at) FILTER (WHERE type = 'clock_in')
        )) / 3600, 2
    )                                                               AS work_hours
FROM attendances
GROUP BY user_id, DATE(timestamp_at);

-- ============================================================
-- 10. TASKS & AKTIVITAS
-- ============================================================

CREATE TABLE tasks (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title       VARCHAR(255) NOT NULL,
    description TEXT,
    status      task_status NOT NULL DEFAULT 'pending',
    priority    task_priority NOT NULL DEFAULT 'medium',
    assigned_to UUID REFERENCES users(id) ON DELETE SET NULL,
    created_by  UUID REFERENCES users(id),
    customer_id UUID REFERENCES customers(id) ON DELETE SET NULL,
    deal_id     UUID REFERENCES deals(id) ON DELETE SET NULL,
    due_at      TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_tasks_assigned ON tasks(assigned_to, status);
CREATE INDEX idx_tasks_due      ON tasks(due_at) WHERE status NOT IN ('done', 'cancelled');

-- Riwayat interaksi dengan pelanggan
CREATE TABLE activities (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    type        VARCHAR(50) NOT NULL,               -- 'call','email','meeting','note','whatsapp'
    subject     VARCHAR(255),
    body        TEXT,
    customer_id UUID REFERENCES customers(id) ON DELETE CASCADE,
    contact_id  UUID REFERENCES contacts(id),
    deal_id     UUID REFERENCES deals(id),
    visit_id    UUID REFERENCES visits(id),
    created_by  UUID REFERENCES users(id),
    activity_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_activities_customer ON activities(customer_id, activity_at DESC);
CREATE INDEX idx_activities_deal     ON activities(deal_id);

-- ============================================================
-- 11. TARGET PENJUALAN
-- ============================================================

CREATE TABLE sales_targets (
    id                   UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id              UUID NOT NULL REFERENCES users(id),
    period_year          SMALLINT NOT NULL,
    period_month         SMALLINT NOT NULL CHECK (period_month BETWEEN 1 AND 12),
    target_revenue       NUMERIC(15,2),
    target_visits        INT,
    target_deals         INT,
    target_new_customers INT,
    created_by           UUID REFERENCES users(id),
    created_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, period_year, period_month)
);

CREATE INDEX idx_targets_user ON sales_targets(user_id, period_year, period_month);

-- ============================================================
-- 12. NOTIFIKASI
-- ============================================================

CREATE TABLE notifications (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type        notification_type NOT NULL,
    title       VARCHAR(255) NOT NULL,
    body        TEXT,
    entity_type VARCHAR(100),
    entity_id   UUID,
    is_read     BOOLEAN NOT NULL DEFAULT FALSE,
    read_at     TIMESTAMPTZ,
    sent_at     TIMESTAMPTZ,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notif_user ON notifications(user_id, is_read, created_at DESC);

-- ============================================================
-- 13. KONFIGURASI APLIKASI
-- ============================================================

CREATE TABLE app_settings (
    key         VARCHAR(100) PRIMARY KEY,
    value       JSONB NOT NULL,
    description TEXT,
    updated_by  UUID REFERENCES users(id),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO app_settings (key, value, description) VALUES
('visit.checkin_radius_default',   '100',                      'Default radius check-in (meter)'),
('tracking.interval_seconds',      '30',                       'Interval kirim GPS saat bergerak (detik)'),
('tracking.idle_interval_seconds', '120',                      'Interval kirim GPS saat diam (detik)'),
('tracking.work_start_hour',       '7',                        'Jam mulai tracking otomatis (WIB)'),
('tracking.work_end_hour',         '18',                       'Jam selesai tracking otomatis (WIB)'),
('photo.max_size_kb',              '5120',                     'Ukuran maksimum foto kunjungan (KB)'),
('photo.allowed_types',            '["image/jpeg","image/png","image/webp"]', 'Tipe file foto yang diizinkan'),
-- Storage lokal VPS
('storage.upload_base_path',       '"/app/uploads"',           'Root folder penyimpanan file di VPS (diakses Gin)'),
('storage.visit_photos_path',      '"visits/{YYYY}/{MM}/{DD}/{visit_id}"', 'Pola subfolder foto kunjungan'),
('storage.attendance_photos_path', '"attendance/{YYYY}/{MM}"', 'Subfolder foto absensi'),
('storage.base_url',               '"https://yourdomain.com/uploads"', 'Base URL static file server Gin (/uploads route)');

-- ============================================================
-- 14. MATERIALIZED VIEW: KPI SALES BULANAN
-- ============================================================

CREATE MATERIALIZED VIEW mv_sales_monthly_kpi AS
SELECT
    u.id                                        AS sales_id,
    u.name                                      AS sales_name,
    DATE_TRUNC('month', v.checkin_at)           AS month,
    COUNT(v.id)                                 AS total_visits,
    COUNT(v.id) FILTER (WHERE v.status = 'completed')           AS completed_visits,
    COUNT(v.id) FILTER (WHERE v.checkin_is_valid = TRUE)        AS valid_checkins,
    ROUND(AVG(v.duration_minutes))              AS avg_visit_duration_min,
    ROUND(SUM(ts.total_distance) / 1000, 2)     AS total_distance_km,
    COUNT(DISTINCT v.customer_id)               AS unique_customers_visited
FROM users u
LEFT JOIN visits v
    ON v.sales_id = u.id
LEFT JOIN tracking_sessions ts
    ON ts.sales_id = u.id AND ts.session_date = DATE(v.checkin_at)
WHERE u.role = 'sales'
GROUP BY u.id, u.name, DATE_TRUNC('month', v.checkin_at);

CREATE UNIQUE INDEX ON mv_sales_monthly_kpi(sales_id, month);
-- Jalankan setiap malam via cron:
-- REFRESH MATERIALIZED VIEW CONCURRENTLY mv_sales_monthly_kpi;

-- ============================================================
-- 15. FUNCTIONS & TRIGGERS
-- ============================================================

-- Auto-update kolom updated_at
CREATE OR REPLACE FUNCTION fn_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE t TEXT;
BEGIN
    FOREACH t IN ARRAY ARRAY[
        'users','customers','contacts','leads','deals',
        'visit_schedules','visits','tracking_sessions',
        'tasks','territories','products','sales_targets'
    ] LOOP
        EXECUTE format('
            CREATE TRIGGER trg_updated_at
            BEFORE UPDATE ON %I
            FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();
        ', t);
    END LOOP;
END;
$$;

-- Validasi jarak check-in terhadap koordinat pelanggan
CREATE OR REPLACE FUNCTION fn_validate_checkin_distance(
    p_customer_id   UUID,
    p_checkin_point GEOMETRY
) RETURNS TABLE(is_valid BOOLEAN, distance_meters FLOAT) AS $$
DECLARE
    v_location  GEOMETRY;
    v_radius    INT;
    v_distance  FLOAT;
BEGIN
    SELECT location, checkin_radius
    INTO v_location, v_radius
    FROM customers WHERE id = p_customer_id;

    v_distance := ST_Distance(
        v_location::GEOGRAPHY,
        p_checkin_point::GEOGRAPHY
    );

    RETURN QUERY SELECT (v_distance <= v_radius), v_distance;
END;
$$ LANGUAGE plpgsql;

-- Rebuild polyline rute dari kumpulan GPS points satu sesi
CREATE OR REPLACE FUNCTION fn_rebuild_session_route(p_session_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE tracking_sessions SET
        route          = sub.line,
        total_distance = sub.dist
    FROM (
        SELECT
            ST_MakeLine(location ORDER BY recorded_at) AS line,
            ST_Length(
                ST_MakeLine(location ORDER BY recorded_at)::GEOGRAPHY
            )                                          AS dist
        FROM gps_points
        WHERE session_id = p_session_id
    ) sub
    WHERE id = p_session_id;
END;
$$ LANGUAGE plpgsql;

-- Auto-assign territory berdasarkan lokasi pelanggan (saat insert/update koordinat)
CREATE OR REPLACE FUNCTION fn_auto_assign_territory()
RETURNS TRIGGER AS $$
DECLARE v_territory_id UUID;
BEGIN
    IF NEW.location IS NOT NULL THEN
        SELECT id INTO v_territory_id
        FROM territories
        WHERE status = 'active'
          AND ST_Contains(geom, NEW.location)
        LIMIT 1;

        IF v_territory_id IS NOT NULL THEN
            NEW.territory_id = v_territory_id;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_customer_auto_territory
BEFORE INSERT OR UPDATE OF location ON customers
FOR EACH ROW EXECUTE FUNCTION fn_auto_assign_territory();

-- ============================================================
-- 16. ROW LEVEL SECURITY (RLS)
-- ============================================================
-- Aktifkan di production.
-- Set sebelum query: SET LOCAL app.current_user_id = '...';
--                    SET LOCAL app.current_user_role = 'sales';

ALTER TABLE customers          ENABLE ROW LEVEL SECURITY;
ALTER TABLE visits             ENABLE ROW LEVEL SECURITY;
ALTER TABLE gps_points         ENABLE ROW LEVEL SECURITY;

CREATE POLICY policy_customers ON customers FOR SELECT USING (
    assigned_to = current_setting('app.current_user_id', TRUE)::UUID
    OR current_setting('app.current_user_role', TRUE) IN ('manager','supervisor','super_admin')
);

CREATE POLICY policy_visits ON visits FOR SELECT USING (
    sales_id = current_setting('app.current_user_id', TRUE)::UUID
    OR current_setting('app.current_user_role', TRUE) IN ('manager','supervisor','super_admin')
);

CREATE POLICY policy_gps_points ON gps_points FOR SELECT USING (
    sales_id = current_setting('app.current_user_id', TRUE)::UUID
    OR current_setting('app.current_user_role', TRUE) IN ('manager','supervisor','super_admin')
);

-- ============================================================
-- RINGKASAN SCHEMA v1.1
-- ============================================================
--
-- Tabel           : 26 tabel
-- View            :  1 (daily_attendance)
-- Materialized    :  1 (mv_sales_monthly_kpi)
-- Functions       :  4 (updated_at, validate_checkin, rebuild_route, auto_territory)
-- Triggers        : 13 (updated_at) + 1 (auto_territory)
-- Partisi         : gps_points — 12 partisi per bulan (2026)
--
-- Storage File (VPS Lokal, tanpa backup eksternal):
--   Foto kunjungan : /app/uploads/visits/{YYYY}/{MM}/{DD}/{visit_id}/
--   Foto absensi   : /app/uploads/attendance/{YYYY}/{MM}/
--   Avatar user    : /app/uploads/avatars/
--   Diakses via    : Gin static file server
--                    router.Static("/uploads", "./uploads")
--
-- Spatial Indexes (GIST):
--   customers.location          → radius check-in & peta pelanggan
--   visits.checkin_location     → query kunjungan per area
--   visit_photos.location       → GPS saat foto diambil
--   tracking_sessions.route     → polyline rute harian
--   gps_points.location         → query titik GPS
--   sales_live_positions        → real-time map
--   territories.geom            → polygon area kerja
--
-- Extensions: uuid-ossp, postgis, pg_trgm
-- ============================================================
