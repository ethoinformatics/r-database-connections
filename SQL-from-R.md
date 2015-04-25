# Connecting from R to an SQL format database

There are several R libraries that all you to connect to SQL databases from R

library(sqldf)
library(RMySQL)
library(RSQLite)
library(RPostgreSQL)

#EXAMPLE
Connect to a MySQL database named `pp` running in a local MAMP installation (localhost, on port 8889)

1. Start MAMP, MySQL server, and Apache server
2. Open R

	> library(RMySQL)
	> con <- dbConnect(MySQL(), user = 'root', password = 'root', host = 'localhost', unix.socket = '/Applications/MAMP/tmp/mysql/mysql.sock', port = 8889, dbname='pp')

SQLite


PostgreSQL


