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

for lib in $(ls `dirname $0`/lib/*.sh); do source $lib; done

root="$(dirname "$(readlink_f "${0}")")"

output_log_32bit="$root/32bit.log"
output_log_64bit="$root/64bit.log"

if [ -n "${ARACHNI_OSX_BUILD_AND_PACKAGE+x}" ]; then
    output_log_osx="$root/osx.log"
    rm -f $output_log_osx
fi

mkdir -p `build_dir`
cd `build_dir`

if ls *.lock > /dev/null 2>&1; then
    echo "Found a lock file, another build process is in progress or the dir is dirty.";
    exit 1
fi

if ls *.pid > /dev/null 2>&1; then
    echo "Found a pid file, another build process is in progress or the dir is dirty.";
    exit 1
fi

rm -f $(package_patterns)

rm -f $output_log_32bit
rm -f $output_log_64bit

echo "Building packages, this can take a while; to monitor the progress of the:"
echo "  * 32bit build: tail -f $output_log_32bit"
echo "  * 64bit build: tail -f $output_log_64bit"


if [ -n "${ARACHNI_OSX_BUILD_AND_PACKAGE+x}" ]; then
    echo "  * OSX build: tail -f $output_log_osx"
fi

echo
echo 'You better go grab some coffee now...'

bash -c "touch 32bit_build.lock && \
    bash $root/cross_build_and_package.sh 2>> $output_log_32bit 1>> $output_log_32bit ;\
    rm 32bit_build.lock" &

echo $! > 32bit.pid

bash -c "touch 64bit_build.lock && \
    bash $root/build_and_package.sh 2>> $output_log_64bit 1>> $output_log_64bit &&\
    rm 64bit_build.lock" &

echo $! > 64bit.pid

if [ -n "${ARACHNI_OSX_BUILD_AND_PACKAGE+x}" ]; then
    bash -c "touch osx_build.lock && \
        eval \"$ARACHNI_OSX_BUILD_AND_PACKAGE\" 2>> $output_log_osx 1>> $output_log_osx &&\
        rm osx_build.lock" &

    echo $! > 64bit.pid
fi

# wait for the locks to be created
while [ ! -e "32bit_build.lock" ]; do sleep 0.1; done
while [ ! -e "64bit_build.lock" ]; do sleep 0.1; done

if [ -n "${ARACHNI_OSX_BUILD_AND_PACKAGE+x}" ]; then
    while [ ! -e "osx_build.lock" ]; do sleep 0.1; done
fi


# and then wait for the locks to be removed
while [ -e "32bit_build.lock" ]; do sleep 0.1; done
echo '  * 32bit package ready'

while [ -e "64bit_build.lock" ]; do sleep 0.1; done
echo '  * 64bit package ready'

if [ -n "${ARACHNI_OSX_BUILD_AND_PACKAGE+x}" ]; then
    while [ -e "osx_build.lock" ]; do sleep 0.1; done
    echo '  * OSX package ready'
fi


echo
echo -n 'Removing PID files'
rm *.pid
echo ' - done.'
echo

echo 'Pushing to server, this can also take a while...'
rsync --human-readable --progress --executability --compress --stats \
    $(package_patterns) `rsync_destination`

echo
echo 'All done.'
