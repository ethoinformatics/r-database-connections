#Connecting from `R` to noSQL format database

There are several packages for `R` that let you connect to document-based "noSQL" databases, including `CouchDB` and `MongoDB`. The EthoCore project is recommending (for the time being) Apache's open source `CouchDB` as a noSQL database format for storing and transferring EthoCore documents. The format for `CouchDB` documents is simply JSON ("JavaScript Object Notation") structured text files. The following `R` libraries allow users to connect with sets of `CouchDB` databases.

- library(couchDB)
- library(sofa)
- library(R4CouchDB)

## To get started with `CouchDB`:

1. Download and install the current version of [CouchDB](http://couchdb.apache.org/) for your operating system. Installation instructions are provided [here](http://docs.couchdb.org/en/1.6.1/install/index.html). The online [documentation](http://127.0.0.1:5984/_utils/docs/) for `CouchDB` is very thorough.

2. Start your `CouchDB` application. On Mac OSX this is simply done by double-clicking on the `Apache CouchDB.app`, which should also open a web browser and show you Couch's [**Futon**](http://127.0.0.1:5984/_utils/) utility for creating and administering databases on your local installation (address 127.0.0.1, port 5984).

3. The `CouchDB` [tutorial](http://127.0.0.1:5984/_utils/docs/intro/tour.html) gives a quick overview of how to interface with Couch via the terminal and via the **Futon** brower interface.
 
##Connecting to `CouchDB` and Creating a New Database from `R`

**Method 1: Using the "sofa" library**

Open `R` and install the `sofa` package. A binary installer is not yet available for `sofa` for the most recent versions of `R`, so you will need to first install the `devtools` package and then install `sofa` from the [`ropensci/sofa`](https://github.com/ropensci/sofa) GitHub repo.

````
> install.packages('devtools')
> devtools::install_github("ropensci/sofa")
> library(sofa)
````
The function `cushion` lets us connect to `CouchDB`:

````
> cushion(name = 'cdb', user = '', pwd = '', type = "localhost")
````
We can 'ping' Couch to see if it is running...

````
> ping()
```` 

And we should see something like the following:

````
$couchdb
[1] "Welcome"

$uuid
[1] "31b8e8e07eabc311bda8bc01d78a057a"

$version
[1] "1.6.1"

$vendor
$vendor$version
[1] "1.6.1-1"

$vendor$name
[1] "Homebrew"
````

The `db_list()` command will show us a new list of databases currently stored in Couch. The "\_replicator" and "\_user" databases are created by default.

````
> db_list()
> [1] "_replicator" "_users"
````

We can now make a new database (called `pp`) with the `db_create()` command and then run `db_list()` again:

````
> db_create(dbname='pp')
> db_list()

[1] "_replicator" "_users"      "pp"
````

Let's get some data into the database now. For this, we use the package **jsonlite**, which allows us to dump the contents of an `R` dataframe in JSON format using the `toJSON` function (and to read JSON text files into `R` using `fromJSON`).


````
> library(jsonlite)
> # First we read in some Etho Core style JSON documents...
> path <- "~/Desktop/diary.txt"
> d <-as.data.frame(fromJSON(path))
````

We can add all these to the `pp` Couch database as follows. We first make a document for each row as a **list** of key:values pairs and then add these with `doc_create()`. The code below produces documents in `CouchDB` that have their Etho Core **eventID** as their Couch "\_id"

````
> for (i in 1:nrow(d)){
> 	doc <- as.list(d[i,]) 
> 	doc_create(doc,dbname='pp',docid = d$eventID)
> }
````

We can read these out of `CouchDB` by using `doc_get()` and specifying their Couch "\_id".

````
> for (i in d$eventID) {
>  res <- doc_get(dbname="pp",docid=i)
>  res
> }
````