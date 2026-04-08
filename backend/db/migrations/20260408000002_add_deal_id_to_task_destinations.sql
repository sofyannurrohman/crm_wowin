-- +goose Up
-- +goose StatementBegin
ALTER TABLE task_destinations ADD COLUMN deal_id UUID REFERENCES deals(id) ON DELETE SET NULL;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
ALTER TABLE task_destinations DROP COLUMN deal_id;
-- +goose StatementEnd
