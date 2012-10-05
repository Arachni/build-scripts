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

build_script_tarball="https://github.com/Arachni/build-scripts/tarball/master"

if [ -z "$ARACHNI_BUILD_DIR" ]; then
    build_dir="arachni-build-dir"
else
    build_dir=$ARACHNI_BUILD_DIR
fi


build_scripts_outfile="build-scripts.tar.gz"

mkdir -p $build_dir
cd $build_dir

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
tar xvf $build_scripts_outfile > /dev/null
rm $build_scripts_outfile

echo '  * Starting the build'

echo
echo '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
echo

bash Arachni-build-scripts-*/build.sh
rm -rf Arachni-build-scripts-*

