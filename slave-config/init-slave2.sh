#!/bin/bash
set -e

# Wait for the master to be fully up and ready
sleep 10

# Commands must be run as the 'postgres' user
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Your SQL commands go here
    CREATE SUBSCRIPTION my_subscription
    CONNECTION 'host=pg-master port=5432 dbname=postgres user=postgres password=mysecretpassword'
    PUBLICATION my_publication
    WITH (create_slot = true, enabled = true, slot_name = my_subscription_slot2);
EOSQL
