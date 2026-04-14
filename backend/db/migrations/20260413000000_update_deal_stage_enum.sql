-- +goose Up
-- +goose NO TRANSACTION
ALTER TYPE deal_stage ADD VALUE IF NOT EXISTS 'prospect';
ALTER TYPE deal_stage ADD VALUE IF NOT EXISTS 'survey';
ALTER TYPE deal_stage ADD VALUE IF NOT EXISTS 'negotiation';
ALTER TYPE deal_stage ADD VALUE IF NOT EXISTS 'closing';
ALTER TYPE deal_stage ADD VALUE IF NOT EXISTS 'pre_order';

-- +goose Down
-- Note: PostgreSQL does not support removing values from ENUMs easily.
