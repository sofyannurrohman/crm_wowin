-- +goose Up
-- +goose StatementBegin
ALTER TABLE visits DROP CONSTRAINT IF EXISTS visits_task_destination_id_fkey;
ALTER TABLE visits ADD CONSTRAINT visits_task_destination_id_fkey FOREIGN KEY (task_destination_id) REFERENCES task_destinations(id) ON DELETE SET NULL;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
ALTER TABLE visits DROP CONSTRAINT IF EXISTS visits_task_destination_id_fkey;
ALTER TABLE visits ADD CONSTRAINT visits_task_destination_id_fkey FOREIGN KEY (task_destination_id) REFERENCES task_destinations(id);
-- +goose StatementEnd
