# Connecting from R to a SQL format relational database

There are several R libraries that all allow you to connect to SQL databases from R

```R
library(RMySQL)
library(RPostgreSQL)
library(RSQLite)
library(sqldf)
```


## MySQL example

**We can connect to a MySQL database named `pp` running in a local MAMP installation...**

First, start MAMP and your MySQL and Apache servers. This means you will connect to a 'localhost'. We will use the default port number of '8889' and assume we are connected as the 'root' user. Then open R and use the following:

<!-- We need to edit the below example so that it works off of the sandbox server, not on localhost. Need to create users with own privileges as well. -->

```R
library(RMySQL)
conn <- dbConnect(MySQL(), user = 'root', password = 'root', host = 'localhost', unix.socket = '/Applications/MAMP/tmp/mysql/mysql.sock', port = 8889, dbname='pp')
```

**Alternatively, we can connect to a MySQL database named `pp` running on a remote host...**

The R code below allows us to connect to the same database hosted in our own sandbox server at IP address 104.236.9.143 via the MySQL default communication port number '3306'. Here, we specify the name and password of a particular user who has been given read and write privileges on the database (users and their privileges are set up separately).**

```R
library(RMySQL)
conn <- dbConnect(MySQL(), user = 'ethoguest', password = 'ethoguest', host = '104.236.9.143', port = 3306, dbname='pp')
```

**Once the connection is set up, we can begin using R code to access information about or in the database.**

To get a listing of tables in the MySQL database:

```R
dbListTables(conn)
```

For SQL queries to work well from R, the table names in MySQL should not have spaces. The routine below reads the list of tables from the database, converts spaces and dashes to underscores, and then runs the SQL command `RENAME` on those tables that whose name should change.

```R
dbtables <- dbListTables(conn)

# Identify offending table names (those containing spaces or hyphens)
bad.names <- dbtables[grep('[ -]',dbtables)]

# The function below generates the partial SQL syntax for renaming
# a single offending table name
bad.to.good.names <- function(bad.name) {
		# strings matching a space or hyphen are replaced with an underscore
		good.name <- gsub('[ -]','_',bad.name)

		# The bad and good names are separated by "TO". Grave accents (`) are included for the special case in
		# which the original table name contained spaces.
		paste0('`',bad.name,'` TO ',good.name)
}

# The function above is now applied to each offending table name and returned as an R list using lapply.
partial.sql.query <- lapply(bad.names,bad.to.good.names)

# The items of the above list are now joined into a vector using the c function and collapsed into a single string using a comma separator.
partial.sql.query <- paste(do.call(c, partial.sql.query), collapse=', ')

# The full query can now be assembled by specifying the initial "RENAME TABLE" command and
# adding punctuation (semicolon)
sql.query <- paste0('RENAME TABLE ', partial.sql.query, ';')

# Run the below command to check our work so far
cat(sql.query)

# Finally, run the query using dbSendQuery
dbSendQuery(conn, sql.query)

```

The loop below accomplishes the same goal and may be easier to understand, but runs less efficiently.

```R
for (bad.name in bad.names) {
	# Replace spaces and hyphens with underscores
	good.name <- gsub('[ -]','_',bad.name)

	# Create and send MySQL RENAME query
	# The grave accents (`) are included for the special case
	# in which the original table name contained spaces.

	dbSendQuery(conn,paste0('RENAME TABLE `',bad.name,'` TO ',good.name))
}
```

To create a vector of the new table names in MySQL:

```R
table.names <- dbListTables(conn)

# ... and this is equivalent, but is not connecting to the MySQL database to produce it
table.names <- gsub('[ -]','_',dbtables)
```

To read a table from a MySQL database into R:

```R
# Generically...
# dbReadTable(conn, MySQLTableName)

# So... if there is a table in the MySQL database named "observer_samples"...
observer_samples <- dbReadTable(conn, 'observer_samples')

# To read in a second table called "avistajes"
avistajes <- dbReadTable(conn, 'avistajes')
```

Just as SQL tables should not include spaces, the columns of each table also should not contain spaces. The following script will cycle through each table and rename offending columns.

```R

for (one.table in table.names) {

}

```

**Joins among related tables**

In the `pp` database, `observer_samples` and `avistajes` are joined by a primary key-foreign key relationship. The primary key in the `observer_sample` table is used as a foreign key in `avistajes` to link each `avistaje` to a single `observer_sample`. We can build a "join table" with information from `observer_samples` and `avistajes` in two ways, by running a `JOIN` query on the MySQL database from R or by using the `merge` function in R.

```R

# Joining via SQL using the USING syntax
observer_samples.avistajes <- dbGetQuery(conn, "SELECT * FROM observer_samples JOIN avistajes USING (`Obs Sample ID`)")

# Joining via SQL using the ON syntax
# This syntax is necessary if the two key columns do not share the same name
# Table names must precede columns names when column names are not unique among tables.
observer_samples.avistajes <- dbGetQuery(conn, "SELECT * FROM observer_samples JOIN avistajes ON observer_samples.`Obs Sample ID` = avistajes.`Obs Sample ID`")

# Below is the same join conducted in R using the merge function
observer_samples.avistajes <- merge(observer_samples, avistajes, by = "Obs.Sample.ID")

# Below is the same join including the necessary syntax for when the join column is named differently in the two data frames
observer_samples.avistajes <- merge(observer_samples, avistajes, by.x = "Obs.Sample.ID", by.y = "Obs.Sample.ID")

# Note that in the SQL version of the join, you can choose particular fields to come from the left hand table
```

Once queries are completed, close the connection to the database.

```R
dbDisconnect(conn)
```

##`PostgreSQL` EXAMPLE

**We can connect to a PostgreSQL database named `pp` stored in a local `Postgres.app` installation...**

First, start your `Postgres.app` installation, then open R and use the code below, replacing USERNAME and PASSWORD with the name and password you provided in setting up your `Postgres.app` installation. You will connect to a 'localhost' using the default port number of '5432'.

```R
library(RPostgreSQL)
conn <- dbConnect('PostgreSQL', user = 'USERNAME', password = 'PASSWORD', host = 'localhost', port = 5432, dbname='pp')
```

**Alternatively, we can connect to a PostgreSQL database named `pp` running on a remote host...**

The R code below allows us to connect to the same database hosted in our own sandbox server at IP address 104.236.9.143 via the PostgreSQL default communication port number '5432'. Here, we specify the name and password of a particular user who has been given read and write privileges on the database (users and their privileges are set up separately).**

```R
library(RPostgreSQL)
conn <- dbConnect('PostgreSQL', user = 'ethoguest', password = 'ethoguest', host = '104.236.9.143', port = 5432, dbname='pp')
```

> A CAVEAT: If you try to load the RPostgreSQL library in R after previously loading the RMySQL library and then try to connect to a PostgreSQL database, you may get an error message. This is a known issue with the RMySQL library and its dependencies. Removing the 'conn' object, detaching the RMySQL library, restarting R, and then loading the RPostgreSQL library is a workaround.

```R
rm(conn)
detach("package:RMySQL", unload=TRUE)

# Restart R here. You can do this by pressing Shift-Command-F10 or selecting 'Restart R' under the 'Session' menu in RStudio

library(RPostgreSQL)
conn <- dbConnect('PostgreSQL', user = 'ethoguest', password = 'ethoguest', host = '104.236.9.143', port = 5432, dbname='pp')
```

**Once the connection is set up, we can begin using R code to access information about or in the database.**

```R
dbListTables(conn)
dbtables <- NULL
dbtables$original <- dbListTables(conn)
dbtables$updated <- gsub("[ -]", "_", dbtables$original)
dbtables <- as.data.frame(dbtables)
dbtables <- dbtables[order(dbtables$original),]

SQL <- NULL
for (i in 1:nrow(dbtables)) {
    dbtables$oldname[i] <- dbExistsTable(conn, as.character(dbtables[i,1]))
    dbtables$newname[i] <- dbExistsTable(conn, as.character(dbtables[i,2]))
    if (dbtables$newname[i] == FALSE) {
        SQL[i]<- paste('ALTER TABLE "', dbtables$original[i],'" RENAME TO "', dbtables$updated[i],'"', sep="")
       dbSendQuery(conn, SQL[i])
    }
}
```

> Note that the SQL syntax for renaming a table is different than that used in MySQL! (see the SQL[i] line in the code above)

To run the same `JOIN` query as in the MySQL example above, the syntax is, again, a bit different:

```R
osav_join <- dbGetQuery(conn, 'SELECT * FROM "observer_samples" INNER JOIN "avistajes" ON "observer_samples"."Obs Sample ID" = "avistajes"."Obs Sample ID"')
```

Once queries are completed, close the connection to the database.

```R
dbDisconnect(conn)
```

**Note that `PostgreSQL` and MySQL differ in their use of single and double quotes in queries!**

####Summary of Some Important Differences Between `PostgreSQL` and MySQL - from this [website](https://wiki.postgresql.org/wiki/Things_to_find_out_about_when_moving_from_MySQL_to_PostgreSQL)

*In general, `PostgreSQL` makes a strong effort to conform to existing database standards, where MySQL has a mixed background on this. If you're coming from a background using MySQL or `Microsoft Access`, some of the changes can seem strange (such as not using double quotes to quote string values).*

* *MySQL uses nonstandard '#' to begin a comment line; `PostgreSQL` doesn't. Instead, use '--' (double dash), as this is the ANSI standard, and both databases understand it.*

* *MySQL uses ' or " to quote values (i.e. WHERE name = "John"). This is not the ANSI standard for databases. `PostgreSQL` uses only single quotes for this (i.e. WHERE name = 'John'). Double quotes are used to quote system identifiers; field names, table names, etc. (i.e. WHERE "last name" = 'Smith').*

* *MySQL uses ` (the accent mark or backtick) to quote system identifiers, which is decidedly non-standard.*
* *`PostgreSQL` is case-sensitive for string comparisons. The field "Smith" is not the same as the field "smith". This is a big change for many users from MySQL and other small database systems, like `Microsoft Access`. In `PostgreSQL`, you can either:*

>
	* Use the correct case in your query. (i.e. WHERE lname='Smith')
	* Use a conversion function, like lower() to search. (i.e. WHERE lower(lname)='smith')
	* Use a case-insensitive operator, like ILIKE or ~*

* *Database, table, field and columns names in `PostgreSQL` are case-independent, unless you created them with double-quotes around their name, in which case they are case-sensitive. In MySQL, table names can be case-sensitive or not, depending on which operating system you are using.*

* *`PostgreSQL` and MySQL seem to differ most in handling of dates, and the names of functions that handle dates.*


##`SQLite` EXAMPLE

**Connecting to an `SQLite` database file named `pp.sqlite` on the Desktop in Mac OSX**

Unlike MySQL and `PostgreSQL`, which are server-based databases (though in the examples above, these are set up as locally running servers, i.e., as a "localhost" on a user's own machine, `SQLite` databases are contained in a single file. The R library `RSQLite` allowa easy connection to such databases by using the path to a local copy of the database.

```R
library(RSQLite)
path <- "~/Desktop/pp.sqlite"
conn <- dbConnect(SQLite(),dbname = path)

dbListTables(conn)
dbtables <- NULL
dbtables$original <- dbListTables(conn)
dbtables$updated <- gsub(" ", "_", dbtables$original)
dbtables$updated <- gsub("-", "_", dbtables$updated)
dbtables <- as.data.frame(dbtables)
dbtables <- dbtables[order(dbtables$original),]

SQL <- NULL
for (i in 1:nrow(dbtables)) {
    dbtables$oldname[i] <- dbExistsTable(conn, as.character(dbtables[i,1]))
    dbtables$newname[i] <- dbExistsTable(conn, as.character(dbtables[i,2]))
    if (dbtables$newname[i] == FALSE) {
        SQL[i]<- paste('ALTER TABLE "', dbtables$original[i],'" RENAME TO "', dbtables$updated[i],'"', sep="")
       dbSendQuery(conn, SQL[i])
    }
}

```

Note that the syntax for renaming a table (`"ALTER TABLE xxx RENAME TO xxx"`) is that used in `PostgreSQL`.

**EITHER** of the `JOIN` queries used above for MySQL or `PostgreSQL` can be used to join two tables from `SQLite`:

```R
osav_join <- dbGetQuery(conn, "SELECT * FROM `observer_samples` JOIN `avistajes` WHERE `observer_samples`.`Obs Sample ID` = `avistajes`.`Obs Sample ID`")

osav_join <- dbGetQuery(conn, 'SELECT * FROM "observer_samples" INNER JOIN "avistajes" ON "observer_samples"."Obs Sample ID" = "avistajes"."Obs Sample ID"')
```

Once queries are completed, close the connection to the database.

```R
dbDisconnect(conn)
```
