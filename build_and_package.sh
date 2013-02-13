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

root="$(dirname "$(readlink_f "${0}")")"

pkg_name="arachni-$(date +"%Y%m%d%H%M")"

cat<<EOF

@@@ Building
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

EOF

bash "$root/build.sh" $pkg_name

if [[ "$?" != 0 ]]; then
    echo "============ Building failed."
    exit 1
fi

cat<<EOF

@@@ Packaging
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

EOF

echo
echo "# Checking for script dependencies"
echo '----------------------------------------'
deps="
    awk
    tar
    shasum
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

pkg_name_with_full_version="arachni-`cat $pkg_name/VERSION`"
rm -rf $pkg_name_with_full_version
mv $pkg_name $pkg_name_with_full_version
pkg_name=$pkg_name_with_full_version

archive="$pkg_name-`operating_system`-`architecture`.tar.gz"

echo "  * Compressing build dir ($pkg_name)"
tar czf $archive -C `dirname $(readlink_f $pkg_name )` $pkg_name

shasum $archive | awk '{ print $1 }' > "$archive.sha1"

echo
cat<<EOF
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


Completed successfully!

Archive is at:        `readlink_f $archive`
SHA1 hash file is at: `readlink_f $archive`.sha1

Cheers,
The Arachni team.

EOF
