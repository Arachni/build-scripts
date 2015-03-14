#!/usr/bin/env bash
#
# Copyright 2010-2015 Tasos Laskos <tasos.laskos@arachni-scanner.com>

if [ -z "$ARACHNI_32BIT_LINUX_SSH" ]; then
    echo 'ARACHNI_32BIT_LINUX_SSH has not been set or is empty.'
    exit 1
fi

bash `dirname $0`/bootstrap_remote.sh $ARACHNI_32BIT_LINUX_SSH build_and_package
