#!/usr/bin/env bash
#
# Copyright 2010-2015 Tasos Laskos <tasos.laskos@arachni-scanner.com>

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
		export HTTP_PROXY=$(proxy)
		export http_proxy=$(proxy)
        export ARACHNI_BUILD_BRANCH=$(branch)
        export ARACHNI_FRAMEWORK_REPOSITORY_URL=$(framework_repository_url)
        export PATH=/usr/local/bin:\$PATH
        wget --no-check-certificate -O - https://raw.github.com/Arachni/build-scripts/master/bootstrap.sh | bash -s $2" |
    ssh $host

scp $host:"$remote_build_dir/$(package_patterns)" "$(build_dir)/"
ssh $host "rm -rf $remote_build_dir/$(package_patterns)"
