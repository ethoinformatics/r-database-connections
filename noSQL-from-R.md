#Connecting from `R` to noSQL format database

There are several packages for `R` that let you connect to document-based "noSQL" databases, including `CouchDB` and `MongoDB`. The EthoCore project is recommending (for the time being) Apache's open source `CouchDB` as a noSQL database format for storing and transferring EthoCore documents. The format for `CouchDB` documents is simply JSON ("JavaScript Object Notation") structured text files. The following `R` libraries allow users to connect with sets of `CouchDB` databases.

- library(couchDB)
- library(sofa)
- library(R4CouchDB)

## To get started with `CouchDB`:

1. Download and install the current version of [CouchDB](http://couchdb.apache.org/) for your operating system. Installation instructions are provided [here](http://docs.couchdb.org/en/1.6.1/install/index.html). The online [documentation](http://127.0.0.1:5984/_utils/docs/) for `CouchDB` is very thorough. For Mac OS, we recommend installing the Apache CouchDB native application. For Windows 8, we recommend using the binary installer and approve that you would like to install `CouchDB` as a service and let it be started automatically after installation.

2. Start your `CouchDB` application. On Mac OSX this is simply done by double-clicking on the `Apache CouchDB.app`, which should also open a web browser and show you Couch's [**Futon**](http://127.0.0.1:5984/_utils/) utility for creating and administering databases on your local installation (address 127.0.0.1, port 5984). On Windows 8, `CouchDB` should start as a service upon booting.

3. The `CouchDB` [tutorial](http://127.0.0.1:5984/_utils/docs/intro/tour.html) gives a quick overview of how to interface with Couch via the terminal in Mac OSX and via the **Futon** brower interface (type "127.0.0.1:5984/_utils/" into the address bar in your browser. In Windows 8, too, you can interface with Couch via the **Futon** browswer at the same URL.
 
##Connecting to `CouchDB` and Creating a New Database from `R`

**Method 1: Using the "sofa" library**

Open `R` and install the `sofa` package. A binary installer is not yet available for `sofa` for the most recent versions of `R`, so you will need to first install the `devtools` package and then install `sofa` from the [`ropensci/sofa`](https://github.com/ropensci/sofa) GitHub repo.

```R
install.packages('devtools')
devtools::install_github("ropensci/sofa")
library(sofa)
```
The function `cushion` lets us connect to `CouchDB`:

```R
cushion(name = 'cdb', user = '', pwd = '', type = "localhost")
```
We can 'ping' Couch to see if it is running...

```R
ping()
``` 

And we should see something like the following:

```R
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
```

The `db_list()` command will show us a new list of databases currently stored in Couch. The "\_replicator" and "\_user" databases are created by default.

```R
db_list()

[1] "_replicator" "_users"
```

We can now make a new database (called `pp`) with the `db_create()` command and then run `db_list()` again:

```R
db_create(dbname='pp')
db_list()

[1] "_replicator" "_users"      "pp"
```

Let's get some data into the database now. For this, we use the package **jsonlite**, which allows us to dump the contents of an `R` dataframe in JSON format using the `toJSON` function (and to read JSON text files into `R` using `fromJSON`).


```R
library(jsonlite)
# First we read in some Etho Core style JSON documents...
path <- "~/Desktop/diary.txt"
d <-as.data.frame(fromJSON(path))
```

> NOTE: If you are running this example in Windows 8, the "path" to the desktop will need to be specified differently. The following can be used to specify a comparable path to the "diary.txt" document on the Windows Desktop for a particular user (replace _USERNAME_ with your own username): "C:/Users/_USERNAME_/Desktop/diary.txt"

We can add all of the records in "diary.text" to the `pp` Couch database as follows. We first make a document for each row as a **list** of key:values pairs and then add these with `doc_create()`. The code below produces documents in `CouchDB` that have their Etho Core **eventID** as their Couch "\_id". To do this, we set the `docid` argument of `doc_create()` to **eventID**.

```R
for (i in 1:nrow(d)){
		doc <- as.list(d[i,]) 
		doc_create(doc,dbname="pp",docid = doc$eventID)
	}
```

We can read these out of `CouchDB` by using `doc_get()` and specifying their Couch "\_id".

```R
for (i in d$eventID) {
		res <- doc_get(dbname="pp", docid=i)
		res
	}
```

To update a particular document in `CouchDB`, use `doc_update()`. Here, we update the name of the observer for document "OS17016" from "LAURA ABONDANO" to "TONY DI FIORE" and then change it back. This revises the document in `CouchDB` two times, generating new "\_rev" ids for the same "`_id".

First, we retrieve the doc of interest...

```R 
res <- doc_get(dbname="pp", docid="OS17016")
```
 
Then, retrieve the revision numbers and ids

```R
revs <- revisions(dbname = "pp", docid = "OS17016")
```

To show these...

```R
> revs

[1] "1-a64ef66db2dca7abde957c5b117d6d64"

```

Revision numbers autoincrement (1, 2, 3, ...) and are followed by a dash and then a unique set of 32 random hexademical characters. Every update to the same document (including deleting a document) creates a new revision. The `revisions` function returns a list of revisions in reverse chronological order (most recent first), thus `revs[1]` in our code is the most recent revision.

Now, we update the `activtyBy` field of the doc...

```R
res$activityBy

[1] "LAURA ABONDANO"

res$activityBy <- "TONY DI FIORE"
res$activityBy

[1] "TONY DI FIORE"
```

And we update the `CouchDB` record. **NOTE:** Updating a document requires the `rev=revs[1]` argument to work properly.

```R
doc_update(dbname="pp", doc=res, docid="OS17016", rev=revs[1])

$ok
[1] TRUE

$id
[1] "OS17016"

$rev
[1] "2-3008a284d8f850bd2f65dccc6fcedca0"
```

To check the new record, we use `doc_get()` again...

```R
res <- doc_get(dbname="pp", docid="OS17016")
res$activityBy

[1] "TONY DI FIORE"
```

Using the `revisions()` function, we now see a new entry at position [1] in the list.

```R
revs <- revisions(dbname = "pp", docid = "OS17016")
revs

[1] "2-3008a284d8f850bd2f65dccc6fcedca0"
[2] "1-a64ef66db2dca7abde957c5b117d6d64"

```

Let's change the `activityBy` field back and check the updated record again...

```R
res$activityBy <- "LAURA ABONDANO"
doc_update(dbname="pp", doc=res, docid="OS17016", rev=revs[1])

$ok
[1] TRUE

$id
[1] "OS17016"

$rev
[1] "3-25351fd1084b9f0e96ed6e58ea8c6264"

res <- doc_get(dbname="pp", docid="OS17016")
res$activityBy

[1] "LAURA ABONDANO"

revs <- revisions(dbname = "pp", docid = "OS17016")
revs

[1] "3-25351fd1084b9f0e96ed6e58ea8c6264"
[2] "2-3008a284d8f850bd2f65dccc6fcedca0"
[3] "1-a64ef66db2dca7abde957c5b117d6d64"
```

We can use `doc_delete()` to delete a document...

```R
doc_delete(dbname="pp", docid="OS17016")

$ok
[1] TRUE

$id
[1] "OS17016"

$rev
[1] "4-aaf61ffc112d3f1e932a47e3d810e1bb"
```

Running `doc_get()` then yields a "not found" error message.

```R
res <- doc_get(dbname="pp", docid="OS17016")
res

$error
[1] "not_found"

$reason
[1] "deleted"
```

If we again create a new document with the same "\_id" number (which we used for the `docid` argument in the various **sofa** package functions) and then run the `revisions()` function, we'll see that both `doc_delete()` and `doc_create()` ammended the revision list for the document.

```R
> doc_create(doc, dbname="pp", docid="OS17016")

$ok
[1] TRUE

$id
[1] "OS17016"

$rev
[1] "5-2c9a573ec21cc37cc0109697a606b331"

revs <- revisions(dbname = "pp", docid = "OS17016")
revs

[1] "5-2c9a573ec21cc37cc0109697a606b331"
[2] "4-aaf61ffc112d3f1e932a47e3d810e1bb"
[3] "3-25351fd1084b9f0e96ed6e58ea8c6264"
[4] "2-3008a284d8f850bd2f65dccc6fcedca0"
[5] "1-a64ef66db2dca7abde957c5b117d6d64" 
```