#
# Fixed values
#

export ARACHNI_TARBALL_URL="https://github.com/Arachni/arachni/tarball/$ARACHNI_BUILD_BRANCH"

#
# Options and their defaults -- Set as desired
#

#
# Branch (or tag) to build.
#
# Supported versions are v0.4.1 and later.
#
# Used universally.
#
if [ -z "$ARACHNI_BUILD_BRANCH" ]; then
    export ARACHNI_BUILD_BRANCH="experimental"
    echo "---- No branch/tag specified, defaulting to: $ARACHNI_BUILD_BRANCH"
fi

#
# Rsync destination for the resulting archives.
#
# Used by build_all_and_push.sh
#
if [ -z "$ARACHNI_RSYNC_DEST" ]; then
    export ARACHNI_RSYNC_DEST="segfault@downloads.arachni-scanner.com:www/arachni/downloads/nightlies/"
fi

#
# Working dir for the build and packaging process.
#
# Used by build_all_and_push.sh
#
if [ -z "$ARACHNI_BUILD_DIR" ]; then
    export ARACHNI_BUILD_DIR="$HOME/builds/nightlies"
fi

#
# ARACHNI_OSX_BUILD_AND_PACKAGE
#
# Bash commands used to build a package on an MAC OSX system and then copy it
# over to the working dir.
#
# Used by build_all_and_push.sh
#