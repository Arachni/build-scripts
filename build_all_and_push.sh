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

source `dirname $0`/lib/setenv.sh

targets=`ls "$(dirname "$(readlink_f "${0}")")"/targets/*.sh`

root="$(dirname "$(readlink_f "${0}")")"

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
rm -f *.log

echo "Building packages, this can take a while; to monitor the progress of the:"

for target in $targets; do
    name=$(basename ${target%.sh})
    logfile="$name.log"
    
    rm -f $logfile

    echo "  * $name build: tail -f `readlink_f $logfile`"
done

echo
echo 'You better go grab some coffee now...'

# start building for the targets
for target in $targets; do
    name=$(basename ${target%.sh})
    logfile="$name.log"
    
    bash -c "touch ${name}_build.lock && \
        bash $root/build_target.sh $name 2>> $logfile 1>> $logfile ;\
        rm ${name}_build.lock" &

    echo $! > $name.pid
done

# wait for the processes to start
for target in $targets; do
    name=$(basename ${target%.sh})
    while [ ! -e "${name}_build.lock" ]; do sleep 0.1; done
done

# and now wait for them to finish
for target in $targets; do
    name=$(basename ${target%.sh})
    while [ -e "${name}_build.lock" ]; do sleep 0.1; done
    echo "  * $name package ready"
done


echo
echo -n 'Removing PID files'
rm *.pid
echo ' - done.'
echo

echo 'Pushing to server, this can also take a while...'

MAX_RETRIES=50
i=0
 
# Set the initial return value to failure
false
 
while [ $? -ne 0 -a $i -lt $MAX_RETRIES ]; do
    i=$(($i+1))
    rsync -v --archive --delay-updates --human-readable --progress --partial \
        --executability --compress --stats --timeout=60 \
        $(package_patterns) $(rsync_destination)

    sleep 5
done

if [ $i -eq $MAX_RETRIES ]; then
    echo "Hit maximum number of retries, giving up."
fi

echo
echo 'All done.'
