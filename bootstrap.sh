#!/usr/bin/env bash
#
# Copyright 2010-2016 Tasos Laskos <tasos.laskos@arachni-scanner.com>

build_script_tarball="https://github.com/Arachni/build-scripts/tarball/master"

if [ -z "$ARACHNI_BUILD_DIR" ]; then
    build_dir="arachni-build-dir"
else
    build_dir=$ARACHNI_BUILD_DIR
fi


build_scripts_outfile="build-scripts.tar.gz"

mkdir -p $build_dir
cd $build_dir

# set it to the absolute path
export ARACHNI_BUILD_DIR=`pwd`

cat<<EOF

               Arachni build bootstrap (experimental)
            ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 It will download and run the build scripts, leaving you with a self-contained
 environment with Arachni and all its dependencies installed in it.

     by Tasos Laskos <tasos.laskos@gmail.com>
-------------------------------------------------------------------------

EOF

echo
echo "# Checking for script dependencies"
echo '----------------------------------------'
deps="
    wget
    tar
"
for dep in $deps; do
    echo -n "  * $dep"
    if [[ ! `which "$dep"` ]]; then
        echo " -- FAIL"
        fail=true
    else
        echo " -- OK"
    fi
done

if [[ $fail ]]; then
    echo
    echo "Please install the missing dependencies and try again."
    exit 1
fi

echo
echo "# Bootstrapping"
echo '----------------------------------------'

echo -n "  * Downloading"
echo -n " -  0% ETA:      -s"
wget -c --progress=dot --no-check-certificate $build_script_tarball -O $build_scripts_outfile 2>&1 | \
    while read line; do
        echo $line | grep "%" | sed -e "s/\.//g" | \
        awk '{printf("\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b%4s ETA: %6s", $2, $4)}'
    done

echo -e "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b                           "

echo '  * Extracting'
tar xvf $build_scripts_outfile 2>> /dev/null 1>> /dev/null
rm $build_scripts_outfile

if [[ -z "$1" ]]; then
    callback_script=Arachni-build-scripts-*/build.sh
else
    callback_script=Arachni-build-scripts-*/$1.sh
fi

ls $callback_script 2>> /dev/null 1>> /dev/null
if [[ $? != 0 ]]; then
    echo
    echo "'$1' isn't a valid build-script name."
    exit 1
fi

echo '  * Starting the build'

echo
echo '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
echo

bash $callback_script
rm -rf Arachni-build-scripts-*

