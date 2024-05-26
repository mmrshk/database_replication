# require 'pg'
# require 'time'
#
# begin
#   conn = PG.connect(
#     host: "localhost",      # Use localhost as the host
#     port: 5432,             # Default PostgreSQL port
#     dbname: "postgres",     # Database name
#     user: "postgres",       # Database user
#     password: "mysecretpassword"  # User password
#   )
#
#   100.times do
#     current_time = Time.now.getutc
#     conn.exec_params("INSERT INTO test_table (data, timestamp) VALUES ($1, $2)", ['Hello World', current_time])
#     sleep(10)  # Adjust timing as needed
#   end
# rescue PG::Error => e
#   puts e.message
# ensure
#   conn.close if conn
# end


require 'pg'
require 'time'

begin
  # Establish the connection to the PostgreSQL Docker container
  conn = PG.connect(
    host: "localhost",      # Use localhost as the host
    port: 5432,             # Default PostgreSQL port
    dbname: "postgres",     # Database name
    user: "postgres",       # Database user
    password: "mysecretpassword"  # User password
  )

  # Loop to insert data periodically
  100.times do
    current_time = Time.now.getutc  # Get the current UTC time
    conn.exec_params("INSERT INTO test_table (data, timestamp) VALUES ($1, $2)", ['Hello World', current_time])  # Insert data into the test_table
    puts "Inserted data at #{current_time}"  # Print a message indicating the data was inserted
    sleep(15)  # Wait for 15 seconds before the next insert
  end

rescue PG::Error => e
  puts e.message  # Print any error messages
ensure
  conn.close if conn  # Close the connection if it is open
end
