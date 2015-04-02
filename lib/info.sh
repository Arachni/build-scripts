#!/usr/bin/env bash
#
# Copyright 2010-2015 Tasos Laskos <tasos.laskos@arachni-scanner.com>

# Branch to build
branch(){
    echo $ARACHNI_BUILD_BRANCH
}

# Arachni Framework Git repository to use.
# See: https://github.com/Arachni/arachni-ui-web/blob/experimental/Gemfile#L95
framework_repository_url(){
    echo $ARACHNI_FRAMEWORK_REPOSITORY_URL
}

framework_repository_path(){
    echo $ARACHNI_FRAMEWORK_REPOSITORY_PATH
}

# URL pointing to a tar archive with the Arachni code to be built.
tarball_url(){
    echo $ARACHNI_TARBALL_URL
}

# rsync destination for the resulting packages -- used by build_all_and_push.sh
rsync_destination(){
    echo $ARACHNI_RSYNC_DEST
}

package_patterns(){
    echo "$ARACHNI_PACKAGE_PATTERNS"
}

# Working dir for the build and packaging process -- used by build_all_and_push.sh
build_dir(){
    echo $ARACHNI_BUILD_DIR
}

environment(){
    echo $ARACHNI_BUILD_ENV
}

proxy(){
    echo $ARACHNI_PROXY
}

# OS name of host.
operating_system(){
    uname -s | awk '{print tolower($0)}'
}

# CPU architecture of host.
architecture(){
    if [[ -e "/32bit-chroot" ]]; then
        echo "i386"
    else
        echo `uname -m`
    fi
}
