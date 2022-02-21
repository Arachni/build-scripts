DEPENDENCIES
------------

Due to the use of Chrome, there are external dependencies that need to be met.

Debian
-------

```
sudo apt-get update
sudo apt-get install ca-certificates fonts-liberation libappindicator3-1 \
  libasound2 libatk-bridge2.0-0 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 \
  libexpat1 libfontconfig1 libgbm1 libgcc1 libglib2.0-0 libgtk-3-0 libnspr4 libnss3 \
  libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 \
  libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 \
  libxrender1 libxss1 libxtst6 lsb-release xdg-utils
```

Other
-------

Please use the package manager of your OS to install the aforementioned packages.

DEBUGGING
---------

Please check the log-files under the 'system/logs/' directories for errors or
information that could explain whatever unwanted behavior you may be experiencing.

Web Interface
-------------

Logs about the operation of the web interface can be found under 'system/logs/webui/'.

Scan/Instance/Dispatcher
------------------------

If you are experiencing problems for a given scan and you'd like to gain more
information about its operation you can get debugging information by:

* Starting a Dispatcher with: bin/arachni_rpcd --reroute-to-logfile --debug
* Adding that Dispatcher to the web interface (default address is 'localhost:7331').
* Performing a scan using that Dispatcher.

Detailed operational information about the Instances provided by that Dispatcher
(and their scans) will be available in log-files under 'system/logs/framework/'.
(Each Dispatcher and each Instance get their own log-file.)

KNOWN ERRORS
------------

Database errors/crashes
-------------------------

The web interface uses, by default, an SQLite3 database to allow a configuration-free
out of the box experience, however, this setup is not suitable for larger workloads.

In order to be able to manage a large number of Scans and/or Dispatchers, you'll
have to configure the interface to use a PostgreSQL database by following the
instructions outlined in this Wiki page:

    https://github.com/Arachni/arachni-ui-web/wiki/Database#PostgreSQL

Outdated GLIBC version on Linux
-------------------------------

This package is self-contained but it does have one basic dependency, glibc >= 2.31.
If you haven't updated your system you may see the following message:

    ruby: /lib/libc.so.6: version GLIBC_2.31 not found

or even get a segfault upon startup.

If you do get this error please update your system and try again.

Segmentation fault on OS X
--------------------------

The package and the binaries it bundles were built on OS X 10.8 Mountain Lion,
thus, if you experience segmentation faults while trying to run Arachni please
ensure that you are using the same or later OS X version.
