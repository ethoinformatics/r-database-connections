# Connect to an `Microsoft Access` *.mdb database from `R` on Mac OSX

## 1. Install [homebrew](http://brew.sh/)

```{bash}
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install wget
```

Homebrew installs packages to their own directory inside `/usr/local/Cellar` and then symlinks their files into `/usr/local`

## 2. Install and compile [mdbtools](http://github.com/brianb/mdbtools)

To do this, follow these instructions:

First, make sure you have current installations of:

* [libtool](http://www.gnu.org/software/libtool/)
* [automake](http://www.gnu.org/software/automake/)
* [autoconf](https://www.gnu.org/software/autoconf/)

You can use Homebrew to install these...

```bash
brew install libtool
brew install automake
brew install autoconf
```

Second, you need a current installation of [glib](https://developer.gnome.org/glib/stable/).

```bash
brew install glib
```

If you want to build the SQL engine for use in [mdbtools](http://mdbtools.sourceforge.net/), you'll also need [bison](https://www.gnu.org/software/bison/) or [byacc](http://gnuwin32.sourceforge.net/packages/byacc.htm), and flex.

```bash
brew install bison
brew install flex
```

If you want to build the ODBC driver for use in mdbtools, you'll need [unixodbc](http://www.unixodbc.org/) (version 2.2.10 or
above).

```bash
brew install unixodbc
```

If you want to build `man` pages, you'll need [txt2man](http://mvertes.free.fr/).

```bash
brew install txt2man
```

You also need to install [pkg-config](http://www.freedesktop.org/wiki/Software/pkg-config/) and [gnome-doc-utils](http://ftp.gnome.org/pub/GNOME/sources/gnome-doc-utils/).

```bash
brew install pkg-config
brew install gnome-doc-utils
```

Next, download and unzip the latest version of the [mdbtools-master.zip](http://github.com/brianb/mdbtools) repo from GitHub, then `cd` into that directory and run `autoreconf`. I unzipped the repo in my `Downloads` folder.

```bash
cd ~/Downloads/mdbtools-master
autoreconf -i -f
```

Now, run `configure`.

```bash
./configure --with-unixodbc=/usr/local
```

If that is successful, run `make` to create the mdbtools C programs and the needed libraries.

```bash
make
```

Once mdbtools has been compiled, the generated library folders will be in the `src/libmdb` directory inside of your `mdbtools-master` folder and the utility programs will be in the `src/util` directory inside of `mdbtools-master` folder.

Then run `make install` as to install the libraries and programs to the `/usr/local` directory by default.

```bash
make install
```

This installs a set of lib files into `/usr/local/lib` and the necessary mdbtools binary files into `/usr/local/bin`.

## 3. In your `R` installation (e.g., in `RStudio`), install the package `Hmisc` and load it.

[DOCUMENTATION](http://cran.r-project.org/web/packages/Hmisc/Hmisc.pdf) for `Hmisc`

```R
install.packages("Hmisc")
library(Hmisc)
```

## 4. Connect to an .mdb database from R with the command `mdb.get`.

```R
mdb.get(filename)
```

### EXAMPLE

The following example R script lets you connect to a database named `test.mdb` located on the desktop. Note: the name of your database cannot have spaces in it.

```R
library(Hmisc)

# To read all tables in the database

filename <- "~/Desktop/test.mdb"
db <- mdb.get(filename)

# To print the names of tables in the database

mdb.get(filename, tables=TRUE)

# To import one table, named "observer"

dbtable <- mdb.get(filename, tables='observer')

# To import several tables

db <- mdb.get(filename, tables=c('observer','contacts')
```

Note that the function `mdb.get` reads the data in the tables as CSV data. It can deal with carriage returns in text fields in the database and reads these as newline characters.

### HELPFUL LINKS
[Read data from MS Access into R] (http://web.stanford.edu/~cengel/cgi-bin/anthrospace/mdb-tools-for-mac-105/comment-page-1)

[MDB Tools Info](http://mdbtools.sourceforge.net/)

[MDB Tools GitHub](http://github.com/brianb/mdbtools)
