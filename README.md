# r-database-connections
connecting to different databases from r

CONNECT TO AN MSACCESS MDB DATABASE FROM R ON A MAC

1. Install `homebrew` [brew.sh/]()

	$ ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	$ brew install wget

`homebrew` installs packages to their own directory inside `/usr/local/Cellar` and then symlinks their files into `/usr/local`

## 2. Install `mdb-tools` [github.com/brianb/mdbtools]()

To do this, follow these instructions:

First, you must have reasonably current installations of:

	libtool
	automake
	autoconf

You can use `homebrew` to install these...

	$ brew install libtool
	$ brew install autoconf
	$ brew install automake
