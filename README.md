# Arachni build-scripts

This repository holds scripts which are used to build self-contained packages for Arachni.

## Options

See ```lib/setenv.sh``` for available options.

## Script breakdown

All of these scripts will leave behind a directory called ```arachni-clean```
containing an environment which includes system library dependencies
(like _libxml_, _curl_, _openssl_ and more) and no Gems nor Arachni.

That directory will be used as a base in order to avoid re-downloading,
re-configuring and re-compiling all those dependencies on subsequent runs of
the build scripts.

### bootstrap.sh

**Honors**:

* ```ARACHNI_BUILD_BRANCH``` -- Which branch (or tag) of the Arachni repository to build (defaults to ```experimental```).
* ```ARACHNI_BUILD_DIR``` -- Name of the directory to use for the build process (defaults to ```arachni-build-dir```).

This script will download this repo and start the build process (by running ```build.sh```)
under ```ARACHNI_BUILD_DIR```, ultimately leaving you with a fresh,
self-contained environment for/with Arachni.

Simply run: ```wget -O - https://raw.github.com/Arachni/build-scripts/master/bootstrap.sh | bash```

**Caution**: Running the script again will **REMOVE** the previous environment
so be sure to move any reports (or other important files) out of the old one
before running it again.

### build.sh

**Honors**:

* ```ARACHNI_BUILD_BRANCH```

This script:

* Creates a directory structure to host a fresh environment.
* Downloads all library dependencies and installs them in the environment.
* Downloads Ruby and installs it in the environment.
* Configures Ruby and installs a few vital gems.
* Downloads and installs Arachni in the environment.

The created environment is self-sufficient in providing the required runtime
dependencies for Arachni and can be moved between systems of identical
architecture type without issue.

```
            Arachni builder (experimental)
            ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 It will create an environment, download and install all dependencies in it,
 configure it and install Arachni itself in it.

     by Tasos Laskos <tasos.laskos@gmail.com>
-------------------------------------------------------------------------

Usage: build.sh [build directory]

Build directory defaults to 'arachni'.

If at any point you decide to cancel the process, re-running the script
will continue from the point it left off.
```

### build_and_package.sh

**Honors**:

* ```ARACHNI_BUILD_BRANCH```

Drives ```build.sh``` and generates an archive named ```arachni-<version>-<os>-<arch>.tar.gz```.

### cross_build_and_package.sh

**Honors**:

* ```ARACHNI_BUILD_BRANCH```

Runs ```build_and_package.sh``` from inside a 32bit chroot environment in order
to create 32bit packages.

### build_all_and_push.sh

**Honors**:

* ```ARACHNI_BUILD_DIR```
* ```ARACHNI_OSX_BUILD_AND_PACKAGE```
* ```ARACHNI_RSYNC_DEST```

This script:

* Changes directory to ```ARACHNI_BUILD_DIR```.
* Drives ```build_and_package.sh```, ```cross_build_and_package.sh``` and executes
    the commands in the ```ARACHNI_OSX_BUILD_AND_PACKAGE``` env variable in order
    to build all package types -- except for MS Windows, these must be done somewhat manually.
* Uploads the resulting packages (using ```rsync```) to the destination specified
    in the ```ARACHNI_RSYNC_DEST``` env variable.
