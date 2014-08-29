#!/usr/bin/env bash
#
# Copyright 2010-2014 Tasos Laskos <tasos.laskos@arachni-scanner.com>

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

# Make sure the local Git repository of the Arachni Framework is up to date.
if [ -d $(framework_repository_path) ]; then
    echo "Updating local Git repo: $(framework_repository_path)"
    cd $(framework_repository_path)
    git pull --all
    cd - > /dev/null 2>&1
    echo
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
    sleep 5

    i=$(($i+1))
    rsync -v --archive --delay-updates --human-readable --progress --partial \
        --executability --compress --stats --timeout=60 \
        $(package_patterns) $(rsync_destination)
done

if [ $i -eq $MAX_RETRIES ]; then
    echo "Hit maximum number of retries, giving up."
fi

echo
echo 'All done.'
