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

if [[ ! -z "$1" ]]; then
    # root path
    host="$1"
else
    echo 'No host has been specified.'
    exit 1
fi

remote_build_dir='arachni-build-dir'

ssh $host "rm -rf $remote_build_dir/$(package_patterns)"

echo "export ARACHNI_BUILD_DIR=$remote_build_dir
        export ARACHNI_BUILD_BRANCH=$(branch)
        export PATH=/usr/local/bin:\$PATH
        wget --no-check-certificate -O - https://raw.github.com/Arachni/build-scripts/master/bootstrap.sh | bash -s $2" |
    ssh $host

scp $host:"$remote_build_dir/$(package_patterns)" "$(build_dir)/"
ssh $host "rm -rf $remote_build_dir/$(package_patterns)"
