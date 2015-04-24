# r-database-connections
connecting to different databases from r

#CONNECT TO AN MS ACCESS .MDB DATABASE FROM R ON MAC OS

## 1. Install `homebrew` [brew.sh/](http://brew.sh/)

	$ ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	$ brew install wget

`homebrew` installs packages to their own directory inside `/usr/local/Cellar` and then symlinks their files into `/usr/local`

## 2. Install `mdb-tools` [github.com/brianb/mdbtools](http://github.com/brianb/mdbtools)

To do this, follow these instructions:

First, make sure you have reasonably current installations of:

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
