#!/bin/bash
set -e

# Set PostgreSQL configurations for logical replication
echo "host replication all 0.0.0.0/0 trust" >> ${PGDATA}/pg_hba.conf

# Writing configuration settings to postgresql.conf
cat >> ${PGDATA}/postgresql.conf <<EOF
listen_addresses = '*'
wal_level = logical
max_replication_slots = 4
max_wal_senders = 4
EOF

# Ensure the PostgreSQL service is restarted to apply the new configurations
# This might depend on how your container handles PostgreSQL service management
# Uncomment the following line if your setup supports it, or handle this outside the script
# pg_ctl restart

# Add publication
# Make sure to handle the potential that this might run more than once by checking if the publication exists
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    DO \$\$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'my_publication') THEN
            CREATE PUBLICATION my_publication FOR ALL TABLES;
        END IF;
    END
    \$\$;
EOSQL
