library(RMySQL)

#To create a connection to MySQL from R
conn <- dbConnect(MySQL(), user = 'clara', password = 'clara', host = '104.236.9.143', port = 3306, dbname='mysql_clara')

# List the tables
dbtables <- dbListTables(conn)

# Show the table names
dbtables

# Read in each of the tables
contacts <- dbReadTable(conn, 'contacts')
social_groups <- dbReadTable(conn, 'social_groups')
animals <- dbReadTable(conn, 'animals')
focal_samples <- dbReadTable(conn, 'focal_samples')
focal_behavior <- dbReadTable(conn, 'focal_behavior')

# Write some SQL queries and send them to MySQL
# This first one creates a VIEW on our data that joins "focal samples" with a "focal animal" (i.e., adds a focal ID to a focal sample)
result <- dbSendQuery(conn, "CREATE VIEW focal_sample_view AS SELECT focal_sample_id, animal_id, animal_name, time_start, sex, animal_remarks FROM focal_samples LEFT JOIN animals ON focal_animal=animal_id")

# This one grabs the resultant VIEW table
focal_sample_joined_to_animal <- dbReadTable(conn, "focal_sample_view")

# And this one adds the identity of the partner
focal_observations <- dbGetQuery(conn, "SELECT * FROM focal_behavior LEFT JOIN focal_sample_view USING (focal_sample_id) LEFT JOIN animals ON partner_animal = animals.animal_id")

# Show the focal observations with ID and PARTNER
focal_observations

# This prints out focal behavior in pretty JSON documents
library(jsonlite)
focal_json <- toJSON(focal_observations, pretty=TRUE)
focal_json
detach("package:jsonlite", unload=TRUE)

# Now let's connect to Couch DB from R
library(R4CouchDB)

# First we create a connection to CouchDB
cdb <- cdbIni(serverName="demo.ethoinformatics.org", port=5984, uname = "supermonkey", pwd = "spiderm0nk3y721")

# or

cdb <- cdbIni(serverName="104.236.9.143", port=5984, uname = "supermonkey", pwd = "spiderm0nk3y721")

# To list the databases present in CouchDB, we use cdbListDB()

# This structure for commands is common in CouchDB functions -- give a conn object and send it as an argument to the function
cdb <- cdbListDB(cdb) # returns a list of databases to the variable cdb
cdb$res # shows the results of the function call

# To delete of create a database

cdb$removeDBName <- "couch_clara" # specify the name of the database to delete
cdb <- cdbRemoveDB(cdb) # command to remove the database
cdb$res # show the results of the function call

# To create a new database

cdb$newDBName <- "couch_clara" # specify the name of the database to create
cdb <- cdbMakeDB(cdb) # command to create the database
cdb$res # show the results of the function call

cdb <- cdbListDB(cdb) # check to verify that thedatabase has been created
cdb$res

# Loops through the rows in your focal_observations table, puts them into a list, adds an _id and adds it as a new document to Couch
cdb$DBName <- "couch_clara"
for (i in 1:nrow(focal_observations)){
  doc <- as.list(focal_observations[i,])
  cdb$id <- doc$focal_behavior_id
  cdb$dataList <- doc
  cdb <- cdbAddDoc(cdb)
}

# To read these back out of Couch, we use the function cdbGetDoc() with a 'cdb' object as its argument. In addition to the server name and port (still in place), the 'cdb' object needs to hold the database name ('cdb$DBName') and the '_id' of the document ('cdb$id').

result <- NULL
cdb$DBName <- "couch_clara"
for (i in focal_observations$focal_behavior_id) {
  cdb$id <- i
  cdb <- cdbGetDoc(cdb)
  doc <- as.data.frame(cdb$res) # creates a 1 row dataframe for the returned doc...
  result <- rbind(result,doc) # ...and then binds these row-wise
}

# Let's clean up our column names  in R
names(result)[names(result) == "X_id"] <- "_id"
names(result)[names(result) == "X_rev"] <- "_rev"

# Show the results!
result


install.packages("devtools")
devtools::install_github("nicolewhite/RNeo4j")
library(RNeo4j)
