# Connecting from R to an SQL format database

There are several R libraries that all you to connect to SQL databases from R

- library(sqldf)
- library(RMySQL)
- library(RSQLite)
- library(RPostgreSQL)

#EXAMPLE

Connect to a MySQL database named `pp` running in a local MAMP installation (localhost, on port 8889)

Start MAMP, MySQL server, and Apache server
Open R

	> library(RMySQL)
	> conn <- dbConnect(MySQL(), user = 'root', password = 'root', host = 'localhost', unix.socket = '/Applications/MAMP/tmp/mysql/mysql.sock', port = 8889, dbname='pp')
	> # To get a list tables in the database
	> dbListTables(conn)

For SQL queries to work well from R, the table names in MySQL should not have spaces. The routine below reads the list of tables from the database, converts spaces and dashes to underscores, and then runs the SQL command `RENAME` on those tables that whose name should change.

	> dbtables$original <- dbListTables(conn)
	> dbtables$updated <- gsub(" ", "_", dbtables$original)
	> dbtables$updated <- gsub("-", "_", dbtables$updated)
	> dbtables <- as.data.frame(dbtables)
	> dbtables <- dbtables[order(dbtables$original),]
	>
	> for (i in 1:nrow(dbtables)) {
		dbtables$oldname[i]<- dbExistsTable(con, as.character(dbtables[i,1]))
		dbtables$newname[i]<- dbExistsTable(con, as.character(dbtables[i,2]))
		if (dbtables$newname[i] == FALSE) {
			SQL[i]<- paste("RENAME TABLE `", dbtables$original[i],"` TO `", dbtables$updated[i],"`", sep="")
			dbSendQuery(con, SQL[i])
		}
	> }
	

SQLite


PostgreSQL


