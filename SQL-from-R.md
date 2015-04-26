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
	> # To create a list with names of new table in MySQL
	> t <- dbListTables(conn)
	> 
	> # ... and this is equivalent, but is not connecting to MySQL 
	> t <- dbtables$updated
	
To read a table from a MySQL database into R...
	> # Generically...
	> # df <- dbReadTable(con, MySQLTableName)
	> # So... if there is a table in the MySQL database named "observer_samples"...
	> os <- dbReadTable(con, "observer_samples")
	> # To read in a second table
	> av <- dbReadTable(con, "avistajes")

In the `pp` database, `observer_samples` and `avistajes` are joined by a primary key-foreign key relationship. The primary key in the `observer_sample` table is used as a foreign key in `avistajes` to link each `avistaje` to a single `observer_sample`. We can build a "join table" with information from `observer_samples` and `avistajes` in two ways, by running a JOIN query on the MySQL database from `R` or by using the `merge` function in `R`.

	> # Joining via SQL, using WHERE to indicate the field(s) to JOIN on
	> osav_join <- dbGetQuery(con, "SELECT * FROM `observer_samples` JOIN `avistajes` WHERE `observer_samples`.`Obs Sample ID` = `avistajes`.`Obs Sample ID`")
	>
	> # Joining dataframes in R
	> osav_join <- merge(os, av, by = "Obs.Sample.ID")
	> 
	> # Note tha in the SQL version, you can choose particular fields to come from the left hand table
	
SQLite


PostgreSQL


