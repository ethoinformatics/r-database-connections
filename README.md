# r-database-connections
connecting to different databases from r

#CONNECT TO AN MS ACCESS .MDB DATABASE FROM R ON MAC OS

## 1. Install `homebrew` [http://brew.sh/]()

	$ ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	$ brew install wget

`homebrew` installs packages to their own directory inside `/usr/local/Cellar` and then symlinks their files into `/usr/local`

## 2. Install `mdb-tools` [http://github.com/brianb/mdbtools]()

To do this, follow these instructions:

First, make sure you have reasonably current installations of:

	libtool
	automake
	autoconf

You can use `homebrew` to install these...

	$ brew install libtool
	$ brew install autoconf
	$ brew install automake
