-- Create sales_activities table

-- +goose Up
CREATE TABLE IF NOT EXISTS sales_activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    lead_id UUID REFERENCES leads(id) ON DELETE SET NULL,
    customer_id UUID REFERENCES customers(id) ON DELETE SET NULL,
    deal_id UUID REFERENCES deals(id) ON DELETE SET NULL,
    type VARCHAR(50) NOT NULL, -- 'visit', 'negotiation', 'deal_closing', 'follow_up', 'other'
    title VARCHAR(255) NOT NULL,
    notes TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    activity_at TIMESTAMP NOT NULL DEFAULT NOW(),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Add indexes for common queries
CREATE INDEX IF NOT EXISTS idx_sales_activities_user_id ON sales_activities(user_id);
CREATE INDEX IF NOT EXISTS idx_sales_activities_lead_id ON sales_activities(lead_id);
CREATE INDEX IF NOT EXISTS idx_sales_activities_customer_id ON sales_activities(customer_id);
CREATE INDEX IF NOT EXISTS idx_sales_activities_deal_id ON sales_activities(deal_id);
CREATE INDEX IF NOT EXISTS idx_sales_activities_activity_at ON sales_activities(activity_at);

-- +goose Down
DROP TABLE IF EXISTS sales_activities;

