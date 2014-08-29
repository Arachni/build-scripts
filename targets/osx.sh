#!/usr/bin/env bash
#
# Copyright 2010-2014 Tasos Laskos <tasos.laskos@arachni-scanner.com>

if [ -z "$ARACHNI_OSX_SSH" ]; then
    echo 'ARACHNI_OSX_SSH has not been set or is empty.'
    exit 1
fi

bash `dirname $0`/bootstrap_remote.sh $ARACHNI_OSX_SSH build_and_package
