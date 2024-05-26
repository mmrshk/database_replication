#
#docker-compose down -v
#docker-compose up --build
#
#docker exec -it database_replication-pg-master-1  psql -U postgres -c "CREATE TABLE test_table (id serial PRIMARY KEY, data VARCHAR(255), timestamp TIMESTAMP);"
#docker exec -it database_replication-pg-slave-1  psql -U postgres -c "CREATE TABLE test_table (id serial PRIMARY KEY, data VARCHAR(255), timestamp TIMESTAMP);"
#docker exec -it database_replication-pg-slave-2  psql -U postgres -c "CREATE TABLE test_table (id serial PRIMARY KEY, data VARCHAR(255), timestamp TIMESTAMP);"
#
## run for salves ALTER SUBSCRIPTION my_subscription REFRESH PUBLICATION
#docker exec -it database_replication-pg-slave-1  psql -U postgres -c "ALTER SUBSCRIPTION my_subscription REFRESH PUBLICATION;"
#docker exec -it database_replication-pg-slave-2  psql -U postgres -c "ALTER SUBSCRIPTION my_subscription REFRESH PUBLICATION;"
#
#docker exec -it database_replication-pg-master-1  psql -U postgres -c "INSERT INTO test_table (data, timestamp) VALUES ('master', now());"
#docker exec -it database_replication-pg-slave-1  psql -U postgres -c "SELECT * FROM test_table;"
#docker exec -it database_replication-pg-slave-2  psql -U postgres -c "SELECT * FROM test_table;"


#!/bin/bash

# Bring down any existing Docker Compose setup and remove volumes
docker-compose down -v

# Build and bring up the new Docker Compose setup
docker-compose up --build -d

# Wait for the master to be fully up and ready
sleep 10

# Create the test_table on the master
docker exec -it database_replication-pg-slave1-1  psql -U postgres -c "CREATE TABLE test_table (id serial PRIMARY KEY, data VARCHAR(255), timestamp TIMESTAMP);"
docker exec -it database_replication-pg-slave2-1  psql -U postgres -c "CREATE TABLE test_table (id serial PRIMARY KEY, data VARCHAR(255), timestamp TIMESTAMP);"
docker exec -it database_replication-pg-master-1 psql -U postgres -c "CREATE TABLE IF NOT EXISTS test_table (id serial PRIMARY KEY, data VARCHAR(255), timestamp TIMESTAMP);"

# Refresh the subscriptions on the slave nodes to ensure they synchronize with the master
docker exec -it database_replication-pg-slave1-1 psql -U postgres -c "ALTER SUBSCRIPTION my_subscription REFRESH PUBLICATION;"
docker exec -it database_replication-pg-slave2-1 psql -U postgres -c "ALTER SUBSCRIPTION my_subscription REFRESH PUBLICATION;"

# Insert a row into the test_table on the master
docker exec -it database_replication-pg-master-1 psql -U postgres -c "INSERT INTO test_table (data, timestamp) VALUES ('hello world', now());"

# Verify the data on the slave nodes
echo "Data on Slave 1:"
docker exec -it database_replication-pg-slave1-1 psql -U postgres -c "SELECT * FROM test_table;"

echo "Data on Slave 2:"
docker exec -it database_replication-pg-slave2-1 psql -U postgres -c "SELECT * FROM test_table;"

docker-compose logs -f