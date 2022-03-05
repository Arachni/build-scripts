#!/usr/bin/env bash
#
# Copyright 2010-2022 Ecsypno <http://www.ecsypno.com>

source `dirname $0`/lib/setenv.sh

root="$(dirname "$(readlink_f "${0}")")"

pkg_name="arachni"

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

if [[ `which "sha512sum"` ]]; then
    sha512sum $archive | awk '{ print $1 }' > "$archive.sha512"
else
    shasum -a 512 $archive | awk '{ print $1 }' > "$archive.sha512"
fi

echo
cat<<EOF
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


Completed successfully!

Archive is at:          `readlink_f $archive`
SHA512 hash file is at: `readlink_f $archive`.sha512

Cheers,
The Arachni team.

EOF
