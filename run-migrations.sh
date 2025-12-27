#!/bin/sh
# Migration script for Railway
# This script runs database migrations

if [ -z "$DATABASE_URL" ]; then
    echo "DATABASE_URL not set, constructing from individual variables..."
    if [ -z "$PDB_HOST" ] || [ -z "$PDB_USER" ] || [ -z "$PDB_PASSWORD" ] || [ -z "$PDB_NAME" ]; then
        echo "Error: Database connection variables not set"
        exit 1
    fi
    DATABASE_URL="postgres://${PDB_USER}:${PDB_PASSWORD}@${PDB_HOST}:${PDB_PORT:-5432}/${PDB_NAME}?sslmode=disable"
fi

echo "Running migrations..."
echo "Database: $PDB_NAME"

# Check if migrate command exists
if ! command -v migrate >/dev/null 2>&1; then
    echo "Installing migrate tool..."
    go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest
fi

# Run migrations
migrate -path migrations -database "$DATABASE_URL" up

if [ $? -eq 0 ]; then
    echo "Migrations completed successfully!"
else
    echo "Migration failed!"
    exit 1
fi

