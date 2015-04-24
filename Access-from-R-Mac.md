#Connect to an MS Access .mdb database from `R` on Mac OSX

## 1. Install `homebrew` [brew.sh/](http://brew.sh/)

	$ ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	$ brew install wget

`homebrew` installs packages to their own directory inside `/usr/local/Cellar` and then symlinks their files into `/usr/local`

## 2. Install and compile `mdb-tools` [github.com/brianb/mdbtools](http://github.com/brianb/mdbtools)

To do this, follow these instructions:

First, make sure you have current installations of:

	libtool
	automake
	autoconf

You can use `homebrew` to install these...

	$ brew install libtool
	$ brew install autoconf
	$ brew install automake

Second, you need a current installation of `glib`.

	$ brew install glib

If you want to build the SQL engine for use in `mdbtools`, you'll also need `bison` or `byacc`, and `flex`.

	$ brew install bison
	$ brew install flex

If you want to build the ODBC driver for use in `mdbtools`, you'll need `unixodbc` (version 2.2.10 or
above).

	$ brew install unixodbc

If you want to build `man` pages, you'll need `txt2man`.

	$ brew install txt2man

You also need to install `pkg-config` and `gnome-doc-utils`.

	$ brew install pkg-config
	$ brew install gnome-doc-utils

Next, download and unzip the latest version of the `mdbtools-master.zip` repo from GitHub [https://github.com/brianb/mdbtools](http://github.com/brianb/mdbtools), then `cd` into that directory and run `autoreconf`. I unzipped the repo in my `Downloads` folder.

	$ cd ~/Downloads/mdbtools-master
	$ autoreconf -i -f
	
Now, run `configure`.

	$ ./configure --with-unixodbc=/usr/local

If that is successful, run `make` to create the `mdbtools` C programs and the needed libraries.

	$ make

Once MDB Tools has been compiled, the generated library folders will be in the `src/libmdb` directory inside of your `mdbtools-master` folder and the utility programs will be in the `src/util` directory inside of `mdbtools-master` folder.

Then run `make install` as to install the libraries and programs to the `/usr/local` directory by default.

	$ make install

This installs a set of lib files into `/usr/local/lib` and the necessary MDB Tools binary files into `/usr/local/bin`.

## 3. In your `R` installation (e.g., in `RStudio`), install the package `Hmisc` and load it.

[DOCUMENTATION](http://cran.r-project.org/web/packages/Hmisc/Hmisc.pdf) for `Hmisc`

	> install.package("Hmisc")
	> library(Hmisc)

## 4. Connect to an .mdb database from `R` with the command `mdb.get`.

	> mdb.get(filename)

### EXAMPLE

The following example `R` script lets you connect to a database named `test.mdb` located on the desktop. Note: the name of your database cannot have spaces in it.

	> library(Hmisc)
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
