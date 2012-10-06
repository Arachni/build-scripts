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

ls `dirname $0`/targets/$1.sh 2>> /dev/null 1>> /dev/null
if [[ $? != 0 ]]; then
    echo "'$1' isn't a valid target name, valid names are"
    
    for name in $(ls `dirname $0`/targets/*.sh); do
        echo "  * `basename ${name%.sh}`"
    done
    exit 1
fi

source `dirname $0`/lib/setenv.sh
source `dirname $0`/targets/$1.sh
