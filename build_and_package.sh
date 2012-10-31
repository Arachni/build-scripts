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

source `dirname $0`/lib/setenv.sh

root="$(dirname "$(readlink_f "${0}")")"

echo "---- Building version: `version`"

pkg_name="arachni-`version`"
archive="$pkg_name-`operating_system`-`architecture`.tar.gz"

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

echo "  * Compressing build dir ($pkg_name)"
tar czf $archive -C `dirname $(readlink_f $pkg_name )` $pkg_name

sha1sum $archive | awk '{ print $1 }' > "$archive.sha1"

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
