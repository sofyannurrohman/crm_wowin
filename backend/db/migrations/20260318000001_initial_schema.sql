-- +goose Up
-- +goose StatementBegin
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";
-- +goose StatementEnd

-- 1. Users Table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL DEFAULT 'sales',
    status VARCHAR(50) NOT NULL DEFAULT 'active',
    avatar_path TEXT,
    manager_id UUID REFERENCES users(id) ON DELETE SET NULL,
    employee_code VARCHAR(50) UNIQUE,
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Refresh Tokens Table
CREATE TABLE IF NOT EXISTS refresh_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    revoked BOOLEAN DEFAULT FALSE,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Territories Table
CREATE TABLE IF NOT EXISTS territories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    geom GEOMETRY(POLYGON, 4326),
    color VARCHAR(20),
    status VARCHAR(50) DEFAULT 'active',
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Territory Users Table
CREATE TABLE IF NOT EXISTS territory_users (
    territory_id UUID NOT NULL REFERENCES territories(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    assigned_by UUID REFERENCES users(id),
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (territory_id, user_id)
);

-- 5. Customers Table
CREATE TABLE IF NOT EXISTS customers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(100) UNIQUE,
    type VARCHAR(50) NOT NULL, -- personal / company
    name VARCHAR(255) NOT NULL,
    company_name VARCHAR(255),
    industry VARCHAR(100),
    website VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(20),
    phone_alt VARCHAR(20),
    status VARCHAR(50) NOT NULL DEFAULT 'prospect',
    address TEXT,
    city VARCHAR(100),
    province VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100) DEFAULT 'Indonesia',
    location GEOMETRY(POINT, 4326),
    checkin_radius INTEGER DEFAULT 100, -- meter
    territory_id UUID REFERENCES territories(id) ON DELETE SET NULL,
    assigned_to UUID REFERENCES users(id) ON DELETE SET NULL,
    created_by UUID REFERENCES users(id),
    credit_limit DECIMAL(15, 2) DEFAULT 0,
    payment_terms VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- 6. Contacts Table
CREATE TABLE IF NOT EXISTS contacts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    title VARCHAR(100),
    department VARCHAR(100),
    email VARCHAR(255),
    phone VARCHAR(20),
    phone_alt VARCHAR(20),
    is_primary BOOLEAN DEFAULT FALSE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. Leads Table
CREATE TABLE IF NOT EXISTS leads (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255),
    name VARCHAR(255) NOT NULL,
    company VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(20),
    source VARCHAR(100),
    status VARCHAR(50) NOT NULL DEFAULT 'new',
    assigned_to UUID REFERENCES users(id) ON DELETE SET NULL,
    customer_id UUID REFERENCES customers(id) ON DELETE SET NULL,
    estimated_value DECIMAL(15, 2) DEFAULT 0,
    notes TEXT,
    converted_at TIMESTAMP WITH TIME ZONE,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. Deals Table
CREATE TABLE IF NOT EXISTS deals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    contact_id UUID REFERENCES contacts(id) ON DELETE SET NULL,
    assigned_to UUID REFERENCES users(id) ON DELETE SET NULL,
    stage VARCHAR(50) NOT NULL DEFAULT 'discovery',
    status VARCHAR(50) NOT NULL DEFAULT 'open', -- open / won / lost / abandoned
    amount DECIMAL(15, 2) DEFAULT 0,
    probability INTEGER DEFAULT 0,
    expected_close DATE,
    closed_at TIMESTAMP WITH TIME ZONE,
    lost_reason TEXT,
    description TEXT,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 9. Deal Stage History
CREATE TABLE IF NOT EXISTS deal_stage_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    deal_id UUID NOT NULL REFERENCES deals(id) ON DELETE CASCADE,
    from_stage VARCHAR(50),
    to_stage VARCHAR(50) NOT NULL,
    changed_by UUID REFERENCES users(id),
    notes TEXT,
    changed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 10. Product Categories Table
CREATE TABLE IF NOT EXISTS product_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 11. Products Table
CREATE TABLE IF NOT EXISTS products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_id UUID REFERENCES product_categories(id) ON DELETE SET NULL,
    sku VARCHAR(100) UNIQUE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(15, 2) DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- 12. Deal Items Table
CREATE TABLE IF NOT EXISTS deal_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    deal_id UUID NOT NULL REFERENCES deals(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE SET NULL,
    quantity INTEGER DEFAULT 1,
    unit_price DECIMAL(15, 2) DEFAULT 0,
    discount DECIMAL(15, 2) DEFAULT 0,
    subtotal DECIMAL(15, 2) DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Triggers and Functions for Deals
-- +goose StatementBegin
CREATE OR REPLACE FUNCTION fn_calculate_deal_amount(v_deal_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE deals
    SET amount = COALESCE((SELECT SUM(subtotal) FROM deal_items WHERE deal_id = v_deal_id), 0),
        updated_at = NOW()
    WHERE id = v_deal_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION trg_update_deal_amount()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        PERFORM fn_calculate_deal_amount(NEW.deal_id);
    ELSIF (TG_OP = 'DELETE') THEN
        PERFORM fn_calculate_deal_amount(OLD.deal_id);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;
-- +goose StatementEnd

CREATE TRIGGER trg_deal_items_sync_deal_amount
AFTER INSERT OR UPDATE OR DELETE ON deal_items
FOR EACH ROW EXECUTE FUNCTION trg_update_deal_amount();

-- 13. Attendances Table
CREATE TABLE IF NOT EXISTS attendances (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(20) NOT NULL, -- clock_in / clock_out
    location GEOMETRY(POINT, 4326),
    address TEXT,
    photo_path TEXT,
    device_info TEXT,
    notes TEXT,
    timestamp_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Daily Attendance View
-- +goose StatementBegin
CREATE OR REPLACE VIEW daily_attendance AS
WITH clock_ins AS (
    SELECT user_id, DATE(timestamp_at) as work_date, MIN(timestamp_at) as clock_in
    FROM attendances
    WHERE type = 'clock_in'
    GROUP BY user_id, work_date
),
clock_outs AS (
    SELECT user_id, DATE(timestamp_at) as work_date, MAX(timestamp_at) as clock_out
    FROM attendances
    WHERE type = 'clock_out'
    GROUP BY user_id, work_date
)
SELECT 
    ci.user_id,
    ci.work_date,
    ci.clock_in,
    co.clock_out,
    EXTRACT(EPOCH FROM (co.clock_out - ci.clock_in)) / 3600 as work_hours
FROM clock_ins ci
LEFT JOIN clock_outs co ON ci.user_id = co.user_id AND ci.work_date = co.work_date;
-- +goose StatementEnd

-- 14. Visit Schedules
CREATE TABLE IF NOT EXISTS visit_schedules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sales_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    title VARCHAR(255),
    objective TEXT,
    status VARCHAR(50) NOT NULL DEFAULT 'scheduled', -- scheduled / completed / cancelled
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- 15. Visits Table
CREATE TABLE IF NOT EXISTS visits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    schedule_id UUID REFERENCES visit_schedules(id) ON DELETE SET NULL,
    sales_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    deal_id UUID REFERENCES deals(id) ON DELETE SET NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'in_progress',
    checkin_at TIMESTAMP WITH TIME ZONE,
    checkin_location GEOMETRY(POINT, 4326),
    checkin_distance DECIMAL(10, 2),
    checkout_at TIMESTAMP WITH TIME ZONE,
    checkout_location GEOMETRY(POINT, 4326),
    result_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 16. App Settings Table
CREATE TABLE IF NOT EXISTS app_settings (
    key VARCHAR(100) PRIMARY KEY,
    value JSONB NOT NULL,
    description TEXT,
    updated_by UUID REFERENCES users(id),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

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
('storage.base_url', '"http://localhost:8082/uploads"', 'Base URL static file server Gin (/uploads route)');

-- 17. Tracking Sessions
CREATE TABLE IF NOT EXISTS tracking_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sales_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_date DATE NOT NULL,
    started_at TIMESTAMP WITH TIME ZONE,
    ended_at TIMESTAMP WITH TIME ZONE,
    status VARCHAR(50) NOT NULL DEFAULT 'idle', -- idle / active / paused / completed
    total_distance DECIMAL(10, 2) DEFAULT 0,
    route GEOMETRY(LINESTRING, 4326),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(sales_id, session_date)
);

-- 18. GPS Points
CREATE TABLE IF NOT EXISTS gps_points (
    id BIGSERIAL PRIMARY KEY,
    session_id UUID NOT NULL REFERENCES tracking_sessions(id) ON DELETE CASCADE,
    sales_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    recorded_at TIMESTAMP WITH TIME ZONE NOT NULL,
    location GEOMETRY(POINT, 4326),
    accuracy DECIMAL(8, 2),
    speed DECIMAL(8, 2),
    heading DECIMAL(5, 2),
    altitude DECIMAL(8, 2),
    battery_level INTEGER
);

-- 19. Sales Live Positions
CREATE TABLE IF NOT EXISTS sales_live_positions (
    sales_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    location GEOMETRY(POINT, 4326),
    status VARCHAR(50),
    speed DECIMAL(8, 2),
    heading DECIMAL(5, 2),
    battery_level INTEGER,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 20. Notifications
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    body TEXT,
    entity_type VARCHAR(50), -- deal / lead / task / etc
    entity_id UUID,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP WITH TIME ZONE,
    sent_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Triggers for automatic territory assignment
-- +goose StatementBegin
CREATE OR REPLACE FUNCTION fn_auto_assign_territory()
RETURNS TRIGGER AS $$
BEGIN
    SELECT id INTO NEW.territory_id
    FROM territories
    WHERE ST_Contains(geom, NEW.location)
    LIMIT 1;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- +goose StatementEnd

CREATE TRIGGER trg_customers_auto_assign_territory
BEFORE INSERT OR UPDATE OF location ON customers
FOR EACH ROW EXECUTE FUNCTION fn_auto_assign_territory();


-- +goose Down
DROP TRIGGER IF EXISTS trg_customers_auto_assign_territory ON customers;
DROP FUNCTION IF EXISTS fn_auto_assign_territory();
DROP TABLE IF EXISTS app_settings;
DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS sales_live_positions;
DROP TABLE IF EXISTS gps_points;
DROP TABLE IF EXISTS tracking_sessions;
DROP TABLE IF EXISTS visits;
DROP TABLE IF EXISTS visit_schedules;
DROP VIEW IF EXISTS daily_attendance;
DROP TABLE IF EXISTS attendances;
DROP TRIGGER IF EXISTS trg_deal_items_sync_deal_amount ON deal_items;
DROP FUNCTION IF EXISTS trg_update_deal_amount();
DROP FUNCTION IF EXISTS fn_calculate_deal_amount(UUID);
DROP TABLE IF EXISTS deal_items;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS product_categories;
DROP TABLE IF EXISTS deal_stage_history;
DROP TABLE IF EXISTS deals;
DROP TABLE IF EXISTS leads;
DROP TABLE IF EXISTS contacts;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS territory_users;
DROP TABLE IF EXISTS territories;
DROP TABLE IF EXISTS refresh_tokens;
DROP TABLE IF EXISTS users;
DROP EXTENSION IF EXISTS "postgis";
DROP EXTENSION IF EXISTS "uuid-ossp";
