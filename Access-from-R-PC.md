#Connect to an `Microsoft Access` *.mdb database from `R` on Windows 8

## 1. Register your database in the `ODBC Data Source Administrator`

- If you have Windows 8.1, click on the Start button and select `Control Panels`, then select `Administrative Tools`. Under `Administrative Tools`, double-click on `ODBC Data Sources` (32 or 64 bit, depending on your machine) to open the `ODBC Data Source Administrator`.
- In the `ODBC Data Source Administrator`, choose `Add` and select the appropriate driver from the list. `Choose Microsoft Access Driver (*.mdb, *.accdb)` to read from an MS Access database. Then click on `Finish`.
- Choose a name for your `Data Source Name` (DSN) and then `Select` the appropriate database source. The DSN is completely up to you. You will see a list of available databases. Select the ones you want to associate with the name you just created.
- Once you have finished configuring your data source, you should see the new DSN in the list shown in the `ODBC Data Source Administrator User DSN tab.`

## 2. In your `R` installation (e.g., in `RStudio`), install the package `RODBC` and load it.

[DOCUMENTATION](http://cran.r-project.org/web/packages/RODBC/RODBC.pdf) for `RODBC`

```R
install.packages("RODBC")
library(RODBC)
```

## 3. Set up a connection to an .mdb database from `R` with the command `odbcConnect`.

```R
conn < odbcConnect(dsn, uid="", pwd="")
```

Here, `dsn` is the name of a registered DSN, `uid` is a user ID, and `pwd` is a password to the database, if these are needed.

### EXAMPLE

The following example `R` script lets you connect to a database that you have registered in the `ODBC Data Source Administrator` as `test`.

```R
library(RODBC)
dsn <- "test"

# To connect to the database
conn <-odbcConnect(dsn, uid="", pwd="")

# To list the names of the tables in your database
dbtables <- sqlTables(conn, tableType="TABLE")

# To read the contents of a table into a dataframe
df <- sqlFetch(conn,dbtables$TABLE_NAME)

# To query a table and return contents into a dataframe
sql <-paste("select * from `", dbtables$TABLE_NAME, "`", sep="")
dbquery <- sqlQuery(conn, sql)
# Note: be careful with quotations in query structure

# To close the connection
close(conn)
```
