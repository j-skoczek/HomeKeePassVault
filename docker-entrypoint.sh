#!/usr/bin/env bash
set -euo pipefail

# Keep in sync with compose env
export DB_HOST="${DB_HOST:-db}"
export DB_PORT="${DB_PORT:-5432}"
export DB_USER="${DB_USER:-symfony}"
export DB_PASSWORD="${DB_PASSWORD:-symfony}"
export DB_NAME="${DB_NAME:-homekeepassvault}"

# Make psql non-interactive by providing password
export PGPASSWORD="${DB_PASSWORD}"

# Wait for PostgreSQL to be ready
until pg_isready -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}"; do
  echo "Waiting for postgres..."
  sleep 1
done

# Ensure database exists (connect to postgres for provisioning)
EXISTS=$(psql -h "${DB_HOST}" -U "${DB_USER}" -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='${DB_NAME}'")
if [[ "${EXISTS}" != "1" ]]; then
  echo "Creating database '${DB_NAME}'"
  psql -h "${DB_HOST}" -U "${DB_USER}" -d postgres -c "CREATE DATABASE \"${DB_NAME}\";"
else
  echo "Database '${DB_NAME}' already exists"
fi

# If dependencies are missing (host mount replaced vendor), install them
if [[ ! -f /app/vendor/autoload_runtime.php ]]; then
  echo "vendor not found, running composer install"
  composer install --no-interaction --prefer-dist --optimize-autoloader
fi

# Run the passed command (default: php -S 0.0.0.0:80 -t public)
exec "$@"
