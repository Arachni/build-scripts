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

if [ -z "$ARACHNI_32BIT_CHROOT" ]; then
    echo 'ARACHNI_32BIT_CHROOT has not been set or is empty.'
    exit 1
fi

echo "wget -O - https://raw.github.com/Arachni/build-scripts/master/bootstrap.sh | bash -s build_and_package" |
    schroot --chroot=$ARACHNI_32BIT_CHROOT -p -d ~

chroot_path=`schroot --chroot=$ARACHNI_32BIT_CHROOT --location 2>> /dev/null`

mv $chroot_path/$(build_dir)/$(package_patterns) . &> /dev/null
