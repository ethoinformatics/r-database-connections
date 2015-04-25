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
	> # To list tables in the database
	> dbListTables(conn)
	> 
	> # To rename the tables in the database, replacing spaces and dashes with underscores, and sort alphabetically
	> dbtables$original <- dbListTables(conn)
	> dbtables$updated <- gsub(" ", "_", dbtables$original)
	> dbtables$updated <- gsub(" ", "-", dbtables$updated
	> dbtables <- as.data.frame(dbtables)
	> dbtables <- dbtables[order(dbtables$original),]
	>
	> SQL <- NULL
	> for (i in 1:nrow(dbtables)) {
	>		SQL[i]<- paste("RENAME TABLE `", dbtables[i,1],"` TO `", dbtables[i,2],"`", sep="")
	>		dbSendQuery(con, SQL[i])
	>	}



SQL <- NULL
for (i in 1:nrow(table_list)) {
  SQL[i]<- paste("RENAME TABLE `", table_list[i,1],"` TO `", table_list[i,2],"`", sep="")
}
for (i in 9:71){
  dbSendQuery(con, SQL[i])
}

SQLite


PostgreSQL


