#!/bin/bash
set -e
echo "                        AINEAS CONSULTING (c) 2024 "

# Initialize database if it doesn't exist
if [ ! -s "$PGDATA/PG_VERSION" ]; then
    echo "Initializing PostgreSQL database..."
    
    # Start PostgreSQL
    pg_ctlcluster ${POSTGRES_VERSION} main start  
    until pg_isready -h localhost -p 5432; do
        echo "Waiting for PostgreSQL..."
        sleep 1
    done

    # Create database and user with runtime variables
    gosu postgres psql -c "CREATE DATABASE \"${DB_NAME}\" WITH OWNER \"${DB_USER}\" ENCODING '${DB_ENCODING}' LC_COLLATE = '${DB_LOCALE}' LC_CTYPE = '${DB_LOCALE}' TEMPLATE template0;"
    gosu postgres psql -c "ALTER USER ${DB_USER} WITH PASSWORD '${DB_PASSWORD}';"
    gosu postgres psql -d ${DB_NAME} -c "CREATE EXTENSION postgis;"
fi

# Start PostgreSQL
pg_ctlcluster ${POSTGRES_VERSION} main start

# Wait for PostgreSQL to start
until pg_isready -h localhost -p 5432; do
  echo "Waiting for PostgreSQL to start..."
  sleep 1
done

echo "PostgreSQL is ready to accept connections"

# Keep container running
exec "$@"
