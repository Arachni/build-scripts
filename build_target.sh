#!/usr/bin/env bash
#
# Copyright 2010-2014 Tasos Laskos <tasos.laskos@arachni-scanner.com>

ls `dirname $0`/targets/$1.sh 2>> /dev/null 1>> /dev/null
if [[ $? != 0 ]]; then
    echo "'$1' isn't a valid target name, valid names are"
    
    for name in $(ls `dirname $0`/targets/*.sh); do
        echo "  * `basename ${name%.sh}`"
    done
    exit 1
fi

source `dirname $0`/lib/setenv.sh
source `dirname $0`/targets/$1.sh
