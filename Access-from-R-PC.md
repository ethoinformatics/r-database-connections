#Connect to an MS Access .mdb database from `R` on Windows 8 OS

## 1. Register your database in the ODBC Data Source Administrator

- If you have Windows 8.1, click on the Start button and select `Control Panels`, then select `Administrative Tools`. Under `Administrative Tools`, double-click on `ODBC Data Sources` (32 or 64 bit, depending on your machine) to open the `ODBC Data Source Administrator`.
- In the `ODBC Data Source Administrator`, choose `Add` and select the appropriate driver from the list. `Choose Microsoft Access Driver (*.mdb, *.accdb)` to read from an MS Access database. Then click on `Finish`.
- Choose a name for your `Data Source Name` (DSN) and then `Select` the appropriate database source. The DSN is completely up to you. You will see a list of available databases. Select the ones you want to associate with the name you just created.
- Once you have finished configuring your data source, you should see the new DSN in the list shown in the `ODBC Data Source Administrator User DSN tab.`

## 2. In your `R` installation (e.g., in `RStudio`), install the package `RODBC` and load it.

[DOCUMENTATION](http://cran.r-project.org/web/packages/RODBC/RODBC.pdf) for `RODBC`

	> install.package("RODBC")
	> library(RODBC)

## 3. Connect to an .mdb database from `R` with the command `mdb.get`.

	> mdb.get(filename)

The following example `R` script lets you connect to a database named `test.mdb` located on the desktop. Note: the name of your database cannot have spaces in it.

	> # To read all tables in the database
	> filename <- "~/Desktop/test.mdb"
	> db <- mdb.get(filename)
	> 
	> # To print the names of tables in the database
	> mdb.get(filename, tables=TRUE)
	>
	> # To import one table, named "observer"
	> dbtable <- mdb.get(filename, tables='observer')
	>
	> # To import several tables
	> db <- mdb.get(filename, tables=c('observer','contacts')

Note that the function `mdb.get` reads the data in the tables as CSV data. It can deal with carriage returns in text fields in the database and reads these as newline characters.
