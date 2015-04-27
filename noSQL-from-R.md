#Connecting from `R` to noSQL format database

There `couchDB` library allows you to connect to a CouchDB noSQL database from `R`.

- library(couchR)

##EXAMPLE

**Connecting to a MySQL database named `pp` running in a local MAMP installation (localhost, on port 8889)**

First, start `MAMP` and your `MySQL` and `Apache` servers, then open `R` and use the following:

````
> library(RMySQL)
> conn <- dbConnect(MySQL(), user = 'root', password = 'root', host = 'localhost', unix.socket = '/Applications/MAMP/tmp/mysql/mysql.sock', port = 8889, dbname='pp')
````

To get a list tables in the `MySQL` database:

````
> dbListTables(conn)
````

For SQL queries to work well from `R`, the table names in `MySQL` should not have spaces. The routine below reads the list of tables from the database, converts spaces and dashes to underscores, and then runs the SQL command `RENAME` on those tables that whose name should change.

````
> dbtables <- NULL
> dbtables$original <- dbListTables(conn)
> dbtables$updated <- gsub(" ", "_", dbtables$original)
> dbtables$updated <- gsub("-", "_", dbtables$updated)
> dbtables <- as.data.frame(dbtables)
> dbtables <- dbtables[order(dbtables$original),]
>
> SQL <- NULL
> for (i in 1:nrow(dbtables)) {
>     dbtables$oldname[i]<- dbExistsTable(conn, as.character(dbtables[i,1]))
>     dbtables$newname[i]<- dbExistsTable(conn, as.character(dbtables[i,2]))
>     if (dbtables$newname[i] == FALSE) {
>         SQL[i]<- paste("RENAME TABLE `", dbtables$original[i],"` TO `", dbtables$updated[i],"`", sep="")
>         dbSendQuery(conn, SQL[i])
>    }
> }
````

To create a list of the new table names in `MySQL`:

````
> t <- dbListTables(conn)
> 
> # ... and this is equivalent, but is not connecting to the MySQL database to produce it 
> t <- dbtables$updated
````
	
To read a table from a `MySQL` database into `R`:

````
> # Generically...
> # df <- dbReadTable(conn, MySQLTableName)
> 
> # So... if there is a table in the MySQL database named "observer_samples"...
> os <- dbReadTable(conn, "observer_samples")
> 
> # To read in a second table called "avistajes"
> av <- dbReadTable(conn, "avistajes")
````

**Joins among related tables**

In the `pp` database, `observer_samples` and `avistajes` are joined by a primary key-foreign key relationship. The primary key in the `observer_sample` table is used as a foreign key in `avistajes` to link each `avistaje` to a single `observer_sample`. We can build a "join table" with information from `observer_samples` and `avistajes` in two ways, by running a `JOIN` query on the `MySQL` database from `R` or by using the `merge` function in `R`.

````
> # Joining via SQL, using WHERE to indicate the field(s) to JOIN on
> osav_join <- dbGetQuery(conn, "SELECT * FROM `observer_samples` JOIN `avistajes` WHERE `observer_samples`.`Obs Sample ID` = `avistajes`.`Obs Sample ID`")
>
> # Joining dataframes in R
> osav_join <- merge(os, av, by = "Obs.Sample.ID")
> 
> # Note that in the SQL version, you can choose particular fields to come from the left hand table
````
	
Once queries are completed, close the connection to the database.

````
> dbDisconnect(conn)
````

##EXAMPLE

**Connecting to a `PostgreSQL` database named `pp` running in a local `Postgres.app` installation (localhost, on port 5432)**

Note that the differences from the example above are in the **library**, **conn**, and **SQL[i]** lines:

````
> library(RPostgreSQL)
> conn <- dbConnect("PostgreSQL", user = 'ad26693', password = '', host = 'localhost', port = 5432, dbname='pp')
> dbListTables(conn)
> dbtables <- NULL
> dbtables$original <- dbListTables(conn)
> dbtables$updated <- gsub(" ", "_", dbtables$original)
> dbtables$updated <- gsub("-", "_", dbtables$updated)
> dbtables <- as.data.frame(dbtables)
> dbtables <- dbtables[order(dbtables$original),]
>
> SQL <- NULL
> for (i in 1:nrow(dbtables)) {
>     dbtables$oldname[i] <- dbExistsTable(conn, as.character(dbtables[i,1]))
>     dbtables$newname[i] <- dbExistsTable(conn, as.character(dbtables[i,2]))
>     if (dbtables$newname[i] == FALSE) {
>         SQL[i]<- paste('ALTER TABLE "', dbtables$original[i],'" RENAME TO "', dbtables$updated[i],'"', sep="")
>        dbSendQuery(conn, SQL[i])
>     }
> }
````

To run the same `JOIN` query as in the `MySQL` example above, the syntax is a bit different:

````
> osav_join <- dbGetQuery(conn, 'SELECT * FROM "observer_samples" INNER JOIN "avistajes" ON "observer_samples"."Obs Sample ID" = "avistajes"."Obs Sample ID"')
````
	
**Note that `PostgreSQL` and `MySQL` differ in their use of single and double quotes!**

####Summary of Some Important Differences Between `PostgreSQL` and `MySQL` - from this [website](https://wiki.postgresql.org/wiki/Things_to_find_out_about_when_moving_from_MySQL_to_PostgreSQL)

> *In general, `PostgreSQL` makes a strong effort to conform to existing database standards, where `MySQL` has a mixed background on this. If you're coming from a background using `MySQL` or `Microsoft Access`, some of the changes can seem strange (such as not using double quotes to quote string values).*
 
> * *`MySQL` uses nonstandard '#' to begin a comment line; `PostgreSQL` doesn't. Instead, use '--' (double dash), as this is the ANSI standard, and both databases understand it.*
 
> * *`MySQL` uses ' or " to quote values (i.e. WHERE name = "John"). This is not the ANSI standard for databases. `PostgreSQL` uses only single quotes for this (i.e. WHERE name = 'John'). Double quotes are used to quote system identifiers; field names, table names, etc. (i.e. WHERE "last name" = 'Smith').*

> * *`MySQL` uses ` (accent mark or backtick) to quote system identifiers, which is decidedly non-standard.*
> * *`PostgreSQL` is case-sensitive for string comparisons. The field "Smith" is not the same as the field "smith". This is a big change for many users from `MySQL` and other small database systems, like `Microsoft Access`. In `PostgreSQL`, you can either:*

>	
	*  Use the correct case in your query. (i.e. WHERE lname='Smith')
	* Use a conversion function, like lower() to search. (i.e. WHERE lower(lname)='smith')
	* Use a case-insensitive operator, like ILIKE or ~*

> * *Database, table, field and columns names in `PostgreSQL` are case-independent, unless you created them with double-quotes around their name, in which case they are case-sensitive. In `MySQL`, table names can be case-sensitive or not, depending on which operating system you are using.*

> * *`PostgreSQL` and `MySQL` seem to differ most in handling of dates, and the names of functions that handle dates.*