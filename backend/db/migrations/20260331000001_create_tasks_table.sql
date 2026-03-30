-- Migration: Create tasks table for CRM
CREATE TYPE task_priority AS ENUM ('LOW', 'MEDIUM', 'HIGH');
CREATE TYPE task_status AS ENUM ('TODO', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED');

CREATE TABLE IF NOT EXISTS tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sales_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    customer_id UUID REFERENCES customers(id) ON DELETE SET NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    priority task_priority DEFAULT 'MEDIUM',
    status task_status DEFAULT 'TODO',
    due_date TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_tasks_sales ON tasks(sales_id);
CREATE INDEX idx_tasks_customer ON tasks(customer_id);
CREATE INDEX idx_tasks_status ON tasks(status);
