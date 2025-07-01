#!/bin/bash

set -e
set -u

function create_user_and_database() {
    local database=$1
    echo "  Creating database '$database'"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d postgres <<-EOSQL
        SELECT 'CREATE DATABASE $database'
        WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$database')\gexec
        GRANT ALL PRIVILEGES ON DATABASE $database TO $POSTGRES_USER;
EOSQL
}

# Create root user if it doesn't exist
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d postgres <<-EOSQL
    DO \$\$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'root') THEN
            CREATE USER root WITH PASSWORD 'password';
            ALTER USER root WITH SUPERUSER;
            GRANT ALL PRIVILEGES ON DATABASE postgres TO root;
        END IF;
    END
    \$\$;
EOSQL

if [ -n "$POSTGRES_MULTIPLE_DATABASES" ]; then
    echo "Multiple database creation requested: $POSTGRES_MULTIPLE_DATABASES"
    for db in $(echo $POSTGRES_MULTIPLE_DATABASES | tr ',' ' '); do
        create_user_and_database $db
        # Grant privileges to root user on each database
        psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" -d postgres -c "GRANT ALL PRIVILEGES ON DATABASE $db TO root;"
    done
    echo "Multiple databases created"
fi