#!/usr/bin/env bash
#
# Copyright 2010-2013 Tasos Laskos <tasos.laskos@gmail.com>
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

# Branch to build
branch(){
    echo $ARACHNI_BUILD_BRANCH
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
