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

This package is self-contained but it does have one basic dependency, glibc >= 2.12.
If you haven't updated your system for a while you may see the following message:

    ruby: /lib/libc.so.6: version GLIBC_2.12 not found

If you do get this error please update your system and try again.

Segmentation fault on OS X
--------------------------

The package and the binaries it bundles were built on OS X 10.8 Mountain Lion,
thus, if you experience segmentation faults while trying to run Arachni please
ensure that you are using the same or later OS X version.
