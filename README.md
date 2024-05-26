# PSQL Replication

This is a simple example of PSQL replication using Docker. We will have a master database and two slave databases. 
We will perform some experiments to see how the replication works.

## Off topic:
PSQL has 2 types of replication:
- Logical Replication: This is a newer feature that allows you to replicate only a subset of the tables in a database. It is more flexible and allows you to replicate only the data you need.
- Physical Replication: This is the traditional way of replicating data in PSQL. It replicates the entire database to the slave.

In this example, we will use logical replication.

First action is to run the following command to create the tables in the master database:

```
./build.sh
```
To fill the master database with some data, run the following command:

```
ruby data_writer.rb
```
This script will insert 1000 rows in the master database.


Let's start experiment, we will turn off first the slave database and see if the master database is still working:

```
docker-compose stop pg-slave1
```
Wait for a while to fill slave2 database with the data from the master database. And turn on the slave1 database.
Data should be replicated to the slave1 database.

```
docker-compose start pg-slave1

docker-compose exec pg-slave1 psql -U postgres

SELECT * FROM test_table;
```

### Experiment 1
Lets delete last column in a test_table on a slave1 database and see if it will be replicated to the master database:

```
docker-compose exec pg-slave1 psql -U postgres

ALTER TABLE test_table DROP COLUMN timestamp;
```

After deleting the column, we can see that it is not replicated to the master database:
```
postgres=# SELECT COUNT(*) FROM test_table;
 count
-------
    35
(1 row)

 id |    data
----+-------------
  1 | hello world
  2 | Hello World
```

On the other hand slave2 database is still working and the data is replicated to the slave2 database:
```
postgres=# SELECT COUNT(*) FROM test_table;
 count
-------
    43
(1 row)

 id |    data     |         timestamp
----+-------------+----------------------------
  1 | hello world | 2024-05-26 06:48:13.956368
  2 | Hello World | 2024-05-26 11:11:04
  3 | Hello World | 2024-05-26 11:11:14
```

Lets add back a column to the test_table on the slave1 database and see if it will be replicated to the master database.

```
docker-compose exec pg-slave1 psql -U postgres
ALTER TABLE test_table ADD COLUMN timestamp TIMESTAMP;
```
After adding the column, we can see that all data is replicated from master to slave1 database.

### Experiment 2
Lets delete middle column in a test_table on a slave1 database and see if it will be replicated to the master database:

```
docker-compose exec pg-slave1 psql -U postgres

ALTER TABLE test_table DROP COLUMN data;
```

After deleting the column, we can see that master is not replicated to the slave1 database.


Conclusion:

- Column Deletion/Addition: In PSQL replication, schema changes (such as dropping or adding columns) on a slave are not replicated back to the master.
- Data Integrity: PSQL replication will continue to function for data operations (INSERT, UPDATE, DELETE) but not for schema changes made directly on the slaves.