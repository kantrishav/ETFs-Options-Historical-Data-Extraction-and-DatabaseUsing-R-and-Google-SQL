



install.packages("DBI")
install.packages("RMySQL")  # For MySQL
install.packages("RPostgreSQL")  # For PostgreSQL

library(RMySQL)
library(DBI)
library(RPostgreSQL)


# Set up connection parameters
db_user <- "root"
db_password <- ""
db_name <- "example"
db_host <- "35.239.25.100"  # You can find this on the Google Cloud Console

# Connect to the database
con <- dbConnect(
  drv = RMySQL::MySQL(),  # Use RMySQL for MySQL
  dbname = db_name,
  host = db_host,
  user = db_user,
  password = db_password
)


DATA_OPTION <- opts2[,1:19]

dbGetQuery(con, "select * from test_r")

car_data <- mtcars

dbWriteTable(con, name = "my_table_name", value = my_data, overwrite = TRUE)

dbWriteTable(con, name = "OPTION_TEST", value = DATA_OPTION, overwrite = TRUE)



dbGetQuery(con, "select COUNT(*) from OPTION_TEST")

dbGetQuery(con, "SHOW TABLES")

dbDisconnect(con)

# Verify the connection
dbListTables(con)
