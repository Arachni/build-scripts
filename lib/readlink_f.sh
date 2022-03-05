#!/usr/bin/env bash
#
# Copyright 2010-2022 Ecsypno <http://www.ecsypno.com>

# *BSD's readlink doesn't like non-existent dirs so we use this one instead.
readlink_f(){
    # from: http://stackoverflow.com/a/1116890
    # Mac OS specific because readlink -f doesn't work
    if [[ "Darwin" == "$(uname)" ]]; then

        TARGET_FILE=$1

        cd `dirname $TARGET_FILE`
        TARGET_FILE=`basename $TARGET_FILE`

        # Iterate down a (possible) chain of symlinks
        while [ -L "$TARGET_FILE" ]; do
            TARGET_FILE=`readlink $TARGET_FILE`
            cd `dirname $TARGET_FILE`
            TARGET_FILE=`basename $TARGET_FILE`
        done

        # Compute the canonicalized name by finding the physical path
        # for the directory we're in and appending the target file.
        PHYS_DIR=`pwd -P`
        echo $PHYS_DIR/$TARGET_FILE
    else
        readlink -f $1
    fi
}
