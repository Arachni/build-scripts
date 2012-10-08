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

* ```ARACHNI_BUILD_DIR``` -- Name of the directory to use for the build process (defaults to ```arachni-build-dir```).
* Options of the corresponding action script (defaults to ```build``` which runs ```build.sh```)

This script will:

* Change to the ```ARACHNI_BUILD_DIR``` directory (it will create it if it doesn't already exist).
* Download this repository.
* Execute the script that corresponds to the specified action (defaults to ```build``` which runs [build.sh](#buildsh))
 
To get a fresh, self-contained Arachni environment simply run:
```wget -O - https://raw.github.com/Arachni/build-scripts/master/bootstrap.sh | bash```

Or, specify a different action, like so:
```wget -O - https://raw.github.com/Arachni/build-scripts/master/bootstrap.sh | bash -s build_and_package```

**Caution**: Running the script again will **REMOVE** the previous environment
so be sure to move any reports (or other important files) out of the old one
before running it again.

**Notice**: If you accidentally cancel the process don't worry, running it again
will continue from where it left off.

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
git co