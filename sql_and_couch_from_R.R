library(RMySQL)
conn <- dbConnect(MySQL(), user = 'clara', password = 'clara', host = '104.236.9.143', port = 3306, dbname='mysql_clara')
dbtables <- dbListTables(conn)
dbtables

contacts <- dbReadTable(conn, 'contacts')
social_groups <- dbReadTable(conn, 'social_groups')
animals <- dbReadTable(conn, 'animals')
focal_samples <- dbReadTable(conn, 'focal_samples')
focal_behavior <- dbReadTable(conn, 'focal_behavior')

result <- dbSendQuery(conn, "CREATE VIEW focal_sample_view AS SELECT focal_sample_id, animal_id, animal_name, time_start, sex, animal_remarks FROM focal_samples LEFT JOIN animals ON focal_animal=animal_id")

focal_sample_joined_to_animal <- dbReadTable(conn, "focal_sample_view")

focal_observations <- dbGetQuery(conn, "SELECT * FROM focal_behavior LEFT JOIN focal_sample_view USING (focal_sample_id) LEFT JOIN animals ON partner_animal = animals.animal_id")

library(jsonlite)
focal_json <- toJSON(focal_observations, pretty=TRUE)
focal_json
detach("package:jsonlite", unload=TRUE)

library(R4CouchDB)
cdb <- cdbIni(serverName="demo.ethoinformatics.org", port=5984, uname = "supermonkey", pwd = "spiderm0nk3y721")

# or

cdb <- cdbIni(serverName="104.236.9.143", port=5984, uname = "supermonkey", pwd = "spiderm0nk3y721")

# To list the databases present in CouchDB, we use cdbListDB().

cdb <- cdbListDB(cdb) # returns a list of databases to the variable cdb
cdb$res # shows the results of the function call

# To delete of create a database

cdb$removeDBName <- "couch_clara" # specify the name of the database to delete
cdb <- cdbRemoveDB(cdb) # command to remove the database
cdb$res # show the results of the function call

cdb$newDBName <- "couch_clara" # specify the name of the database to create
cdb <- cdbMakeDB(cdb) # command to create the database
cdb$res # show the results of the function call

cdb <- cdbListDB(cdb) # check to verify that the `pp` database has been created
cdb$res

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
# clean up column names
names(result)[names(result) == "X_id"] <- "_id"
names(result)[names(result) == "X_rev"] <- "_rev"

result
