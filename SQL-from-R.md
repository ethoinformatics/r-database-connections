# Connecting from R to an SQL format database

There are several R libraries that all you to connect to SQL databases from R

- library(sqldf)
- library(RMySQL)
- library(RSQLite)
- library(RPostgreSQL)

#EXAMPLE

**Connecting to a MySQL database named `pp` running in a local MAMP installation (localhost, on port 8889)**

First, start MAMP and your MySQL and Apache servers, then open `R` and use the following:

	> library(RMySQL)
	> conn <- dbConnect(MySQL(), user = 'root', password = 'root', host = 'localhost', unix.socket = '/Applications/MAMP/tmp/mysql/mysql.sock', port = 8889, dbname='pp')

To get a list tables in the MySQL database:

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

To create a list of the new table names in MySQL:

	> t <- dbListTables(conn)
	> 
	> # ... and this is equivalent, but is not connecting to the MySQL database to produce it 
	> t <- dbtables$updated
	
To read a table from a MySQL database into R:

	> # Generically...
	> # df <- dbReadTable(con, MySQLTableName)
	> 
	> # So... if there is a table in the MySQL database named "observer_samples"...
	> os <- dbReadTable(conn, "observer_samples")
	> 
	> # To read in a second table called "avistajes"
	> av <- dbReadTable(conn, "avistajes")

* Joins among related tables

In the `pp` database, `observer_samples` and `avistajes` are joined by a primary key-foreign key relationship. The primary key in the `observer_sample` table is used as a foreign key in `avistajes` to link each `avistaje` to a single `observer_sample`. We can build a "join table" with information from `observer_samples` and `avistajes` in two ways, by running a JOIN query on the MySQL database from `R` or by using the `merge` function in `R`.

	> # Joining via SQL, using WHERE to indicate the field(s) to JOIN on
	> osav_join <- dbGetQuery(con, "SELECT * FROM `observer_samples` JOIN `avistajes` WHERE `observer_samples`.`Obs Sample ID` = `avistajes`.`Obs Sample ID`")
	>
	> # Joining dataframes in R
	> osav_join <- merge(os, av, by = "Obs.Sample.ID")
	> 
	> # Note that in the SQL version, you can choose particular fields to come from the left hand table
	
Once queries are completed, close the connection to the database.

	> dbDisconnect(conn)

SQLite


PostgreSQL


