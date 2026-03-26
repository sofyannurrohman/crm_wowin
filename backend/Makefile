# ==============================================================================
# Wowin CRM Backend - Development Makefile
# ==============================================================================

# Variables
APP_NAME=wowin-crm-backend
PORT=8082
DATABASE_URL ?= "postgres://postgres:postgres@localhost:5432/wowin_crm?sslmode=disable"
MIGRATION_DIR=db/migrations

.PHONY: help build run test db-up db-down clean deps lint migrate-up migrate-down migrate-status seed

help: ## Show this help message
	@echo "Usage: make [command]"
	@echo ""
	@echo "Commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

build: ## Build the Go application binary
	@echo "=> Building backend binary..."
	go build -o tmp/$(APP_NAME) cmd/server/main.go

run: ## Run the application locally (without Docker)
	@echo "=> Running the application..."
	go run cmd/server/main.go

test: ## Run tests
	@echo "=> Running tests..."
	go test -v -race -cover ./...

db-up: ## Start the database and redis using Docker Compose
	@echo "=> Starting infrastructure..."
	docker compose up -d postgres redis

db-down: ## Stop the database and redis
	@echo "=> Stopping infrastructure..."
	docker compose down

infra-logs: ## View infrastructure logs
	docker compose logs -f

clean: ## Clean up temporary files and builds
	@echo "=> Cleaning up..."
	rm -rf tmp/*

deps: ## Install and tidy dependencies
	@echo "=> Tidy and download dependencies..."
	go mod tidy
	go mod download

lint: ## Run linter
	@echo "=> Running golangci-lint..."
	golangci-lint run

migrate-up: ## Apply database migrations
	@echo "=> Running database migrations up..."
	GOOSE_DRIVER=postgres GOOSE_DBSTRING=$(DATABASE_URL) go run github.com/pressly/goose/v3/cmd/goose@latest -dir $(MIGRATION_DIR) up

migrate-down: ## Rollback last database migration
	@echo "=> Running database migrations down..."
	GOOSE_DRIVER=postgres GOOSE_DBSTRING=$(DATABASE_URL) go run github.com/pressly/goose/v3/cmd/goose@latest -dir $(MIGRATION_DIR) down

migrate-status: ## Check migration status
	@echo "=> Checking migration status..."
	GOOSE_DRIVER=postgres GOOSE_DBSTRING=$(DATABASE_URL) go run github.com/pressly/goose/v3/cmd/goose@latest -dir $(MIGRATION_DIR) status

seed: ## Seed the database with development data
	@echo "=> Seeding database..."
	DATABASE_URL=$(DATABASE_URL) go run cmd/seeder/main.go
