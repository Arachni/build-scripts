#!/usr/bin/env bash
#
# Copyright 2010-2012 Tasos Laskos <tasos.laskos@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

source `dirname $0`"/lib/readlink_f.sh"
source `dirname $0`"/lib/info.sh"

#
# Fixed values
#

export ARACHNI_TARBALL_URL="https://github.com/Arachni/arachni/tarball/$ARACHNI_BUILD_BRANCH"

export ARACHNI_PACKAGE_PATTERNS="arachni-*.gz arachni-*.gz.sha1"

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
    echo
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
# Absolute path to the working dir for the build and packaging process.
#
# Used by build_all_and_push.sh and bootstrap.sh
#
if [ -z "$ARACHNI_BUILD_DIR" ]; then
    export ARACHNI_BUILD_DIR="$HOME/builds/nightlies"
fi
