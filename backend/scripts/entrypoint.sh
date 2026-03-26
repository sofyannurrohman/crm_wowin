#!/bin/sh

# Exit on first failure
set -e

echo "🚀 Starting Wowin CRM Backend Initialization..."

# 1. Wait for Postgres to be ready
until nc -z postgres 5432; do
  echo "⏳ Waiting for PostgreSQL (postgres:5432) to be available..."
  sleep 2
done

echo "✅ PostgreSQL is reachable"

# 2. Run Database Migrations
echo "📦 Running database migrations up..."
# Be explicit with Driver and DBString to avoid any ambiguity
goose -dir ./db/migrations up

# 3. Handle Seeding (Optional - only in development)
if [ "$SEED_DATABASE" = "true" ]; then
    echo "🌱 Seeding database..."
    # Ensure binary is in the right location and executed from /app
    ./seeder
fi

# 4. Start the Application
echo "🌐 Starting core application engine..."
exec ./main
