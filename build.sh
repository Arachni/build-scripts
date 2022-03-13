#!/usr/bin/env bash
#
# Copyright 2010-2022 Ecsypno <http://www.ecsypno.com>

source `dirname $0`/lib/setenv.sh

cat<<EOF

               Arachni builder (experimental)
            ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 It will create an environment, download and install all dependencies in it,
 configure it and install Arachni itself in it.

     by Tasos Laskos <tasos.laskos@gmail.com>
-------------------------------------------------------------------------

EOF

if [[ "$1" == '-h' ]] || [[ "$1" == '--help' ]]; then
    cat <<EOF
Usage: $0 [build directory]

Build directory defaults to 'arachni'.

If at any point you decide to cancel the process, re-running the script
will continue from the point it left off.

EOF
    exit
fi

echo
echo "# Checking for script dependencies"
echo '----------------------------------------'
deps="
    ar
    gperf
    flex
    wget
    gcc
    g++
    awk
    sed
    grep
    make
    expr
    perl
    tar
    bzip2
    unzip
    git
    python
    nodejs
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
echo "---- Building branch/tag: `branch`"

arachni_tarball_url=`tarball_url`

#
# All system library dependencies in proper installation order.
#
libs=(
    https://ftp.gnu.org/gnu/libidn/libidn-1.11.tar.gz
    https://zlib.net/zlib-1.2.11.tar.gz
    # Stick with the 1.0.1 branch due to:
    #   https://github.com/Arachni/arachni/issues/653
    https://openssl.org/source/openssl-1.0.1q.tar.gz
    https://www.sqlite.org/2015/sqlite-autoconf-3090200.tar.gz
)

if [[ "Darwin" != "$(uname)" ]]; then
    libs+=(
        http://ftp.vim.org/ftp/gnu/ncurses/ncurses-6.3.tar.gz
        https://distfiles.macports.org/heimdal/heimdal-1.5.3.tar.gz
    )
fi

libs+=(
    https://github.com/libffi/libffi/releases/download/v3.4.2/libffi-3.4.2.tar.gz
    https://curl.haxx.se/download/curl-7.46.0.tar.gz
    https://pyyaml.org/download/libyaml/yaml-0.1.6.tar.gz
    https://ftp.postgresql.org/pub/source/v13.3/postgresql-13.3.tar.gz
    https://github.com/jemalloc/jemalloc/releases/download/5.2.1/jemalloc-5.2.1.tar.bz2
    https://cache.ruby-lang.org/pub/ruby/2.7/ruby-2.7.5.tar.gz
)

#
# The script will look for the existence of files whose name begins with the
# following strings to see if a lib has already been installed.
#
# Their order should correspond to the entries in the 'libs' array.
#
libs_so=(
    libidn
    libz
    libssl
    libsqlite3
)

if [[ "Darwin" != "$(uname)" ]]; then
    libs_so+=(
        libncurses
        libkrb5
    )
fi

libs_so+=(
    libffi
    libcurl
    libyaml
    postgresql
    libjemalloc
    ruby
)

if [[ ! -z "$1" ]]; then
    # root path
    root="$1"
else
    # root path
    root="arachni"
fi

clean_build="arachni-clean"
if [[ -d $clean_build ]]; then

    echo
    echo "==== Found backed up clean build ($clean_build), using it as base."

    rm -rf $root
    cp -R $clean_build $root
else
    mkdir -p $root
fi

update_clean_dir=false

# Directory of this script.
scriptdir=`dirname $(readlink_f $0)`

# Root of the package.
root=`readlink_f $root`

# Holds a base system dir layout where the dependencies will be installed.
system_path="$root/.system"

# Build directories holding downloaded archives, sources, build logs, etc.
build_path="$root/build"

# Holds tarball archives.
archives_path="$build_path/archives"

# Holds extracted source archives.
src_path="$build_path/src"

# Keeps logs of STDERR and STDOUT for the build/install operations.
logs_path="$build_path/logs"

# --prefix value for 'configure' scripts
configure_prefix="$system_path/usr"
usr_path=$configure_prefix

# Gem storage directories
gem_home="$system_path/gems"
gem_path=$gem_home

#
# Special config for packages that need something extra.
# These are called dynamically using the obvious naming convention.
#
# For some reason assoc arrays don't work...
#

if [[ "Darwin" == "$(uname)" ]]; then
    export CXX=clang++
    export GYPFLAGS=-Dmac_deployment_target=$(defaults read loginwindow SystemVersionStampAsString)
fi

configure_zlib="CFLAGS=\"-m64\" ./configure"

configure_postgresql="./configure --without-readline \
--with-includes=$configure_prefix/include \
--with-libraries=$configure_prefix/lib \
--bindir=$usr_path/bin"

if [[ "Darwin" == "$(uname)" ]]; then
    configure_ruby="./configure --with-opt-dir=$configure_prefix \
--with-libyaml-dir=$configure_prefix \
--with-zlib-dir=$configure_prefix \
--with-openssl-dir=$configure_prefix \
--disable-install-doc --enable-shared"
else
    configure_ruby="./configure --with-opt-dir=$configure_prefix \
--with-libyaml-dir=$configure_prefix \
--with-zlib-dir=$configure_prefix \
--with-jemalloc
--with-jemalloc-dir=$configure_prefix \
--with-openssl-dir=$configure_prefix \
--disable-install-doc --enable-shared"
fi

common_configure_openssl="-I$usr_path/include -L$usr_path/lib \
zlib no-asm no-krb5 shared"

if [[ "Darwin" == "$(uname)" ]]; then
    configure_openssl="./Configure darwin64-x86_64-cc $common_configure_openssl"
else
    configure_openssl="./config $common_configure_openssl"
fi

configure_ncurses="CFLAGS=-fPIC CPPFLAGS=-P ./configure"

configure_heimdal="LIBRARY_PATH=$usr_path/lib LDFLAGS=-lpthread ./configure"

configure_curl="./configure \
--with-ssl=$usr_path \
--with-zlib=$usr_path \
--with-gssapi=$usr_path \
--with-spnego \
--without-librtmp \
--enable-optimize \
--enable-nonblocking \
--enable-threaded-resolver \
--enable-crypto-auth \
--enable-http \
--disable-file \
--disable-ftp \
--disable-ldap \
--disable-ldaps \
--disable-rtsp \
--disable-dict \
--disable-telnet \
--disable-tftp \
--disable-pop3 \
--disable-imap \
--disable-smtp \
--disable-gopher \
--disable-rtmp \
--disable-cookies"

#
# Creates the directory structure for the self-contained package.
#
setup_dirs( ) {
    cd $root

    dirs="
        $build_path/logs
        $build_path/archives
        $build_path/src
        $build_path/tmp
        $root/bin
        $root/logs/framework
        $root/logs/webui
        $system_path/gems
        $system_path/home/arachni
        $system_path/usr/bin
        $system_path/usr/include
        $system_path/usr/info
        $system_path/usr/lib
        $system_path/usr/man
    "
    for dir in $dirs
    do
        echo -n "  * $dir"
        if [[ ! -s $dir ]]; then
            echo
            mkdir -p $dir
        else
            echo " -- already exists."
        fi
    done

    cd - > /dev/null
}

#
# Checks the last return value and exits with an error message on failure.
#
# To be called after each step.
#
handle_failure(){
    rc=$?
    if [[ $rc != 0 ]] ; then
        echo "Build failed, check $logs_path/$1 for details."
        echo "When you resolve the issue you can run the script again to continue where the process left off."
        exit $rc
    fi
}

#
# Downloads the given URL and displays an auto-refreshable progress %.
#
download() {
    echo -n "  * Downloading $1"
    echo -n " -  0% ETA:      -s"
    wget -c --progress=dot $1 $2 2>&1 | \
        while read line; do
            echo $line | grep "%" | sed -e "s/\.//g" | \
            awk '{printf("\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b%4s ETA: %6s", $2, $4)}'
        done

    echo -e "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b                           "
}

#
# Downloads an archive (by URL) and places it under $archives_path.
#
# Calls handle_failure afterwards.
#
download_archive() {
    cd $archives_path

    download $1
    handle_failure $2

    cd - > /dev/null
}

#
# Extracts an archive (by name) under $src_path.
#
extract_archive() {
    if [ -z "$2" ]; then
        dir=$src_path
    else
        dir=$2
    fi

    echo "  * Extracting"
    tar xvf $archives_path/$1*.tar.* -C $dir 2>> $logs_path/$1 1>> $logs_path/$1
    handle_failure $1
}

#
# Installs an extracted archive which is in $src_path, by name.
#
install_from_src() {
    cd $src_path/$1-*

    echo "  * Cleaning"
    make clean 2>> $logs_path/$1 1>> $logs_path/$1

    eval special_config=\$$"configure_$1"
    if [[ $special_config ]]; then
        configure=$special_config
    else
        configure="./configure"
    fi

    configure="${configure} --prefix=$configure_prefix"

    echo "  * Configuring ($configure)"
    echo "Configuring with: $configure" 2>> $logs_path/$1 1>> $logs_path/$1

    eval $configure 2>> $logs_path/$1 1>> $logs_path/$1
    handle_failure $1

    echo "  * Compiling"
    LC_ALL=C LANG=C \
        DYLD_FALLBACK_LIBRARY_PATH=$usr_path/lib \
        DYLD_LIBRARY_PATH=$usr_path/lib \
        LIBRARY_PATH=$usr_path/lib \
        LD_LIBRARY_PATH=$usr_path/lib \
        make 2>> $logs_path/$1 1>> $logs_path/$1

    handle_failure $1

    echo "  * Installing"
    make install 2>> $logs_path/$1 1>> $logs_path/$1
    handle_failure $1

    cd - > /dev/null
}

#
# Gets the name of the given file/directory/URL.
#
get_name(){
    basename $1 | awk -F- '{print $1}'
}

#
# Downloads and install a package by URL.
#
download_and_install() {
    name=`get_name $1`

    download_archive $1 $name
    extract_archive $name
    install_from_src $name
    echo
}

#
# Downloads and installs all $libs.
#
install_libs() {
    libtotal=${#libs[@]}

    for (( i=0; i<$libtotal; i++ )); do
        so=${libs_so[$i]}
        lib=${libs[$i]}
        idx=`expr $i + 1`

        echo "## ($idx/$libtotal) `get_name $lib`"

        so_files="$usr_path/lib/$so"*
        ls  $so_files &> /dev/null
        if [[ $? == 0 ]] ; then
            echo "  * Already installed, found:"
            for so_file in `ls $so_files`; do
                echo "    o $so_file"
            done
            echo
        else
            update_clean_dir=true
            download_and_install $lib
        fi
    done

}

#
# Returns Bash environment configuration.
#
get_ruby_environment() {

    cd "$usr_path/lib/ruby/2.7.0/"

    possible_arch_dir=$(echo `uname -p`*)
    if [[ -d "$possible_arch_dir" ]]; then
        arch_dir=$possible_arch_dir
    fi

    # The running process could be in 32bit compat mode on a 64bit system but
    # Ruby will end up being compiled for 64bit nonetheless so we need to check
    # for that and remedy the situation.
    possible_arch_dir=$(echo x86_64*)
    if [[ -d "$possible_arch_dir" ]]; then
        arch_dir=$possible_arch_dir
    fi

    if [[ -d "$arch_dir" ]]; then
        platform_lib=":\$MY_RUBY_HOME/2.7.0/$arch_dir:\$MY_RUBY_HOME/site_ruby/2.7.0/$arch_dir"
    fi

    cat<<EOF
#
# Environment configuration.
#
# Makes bundled dependencies available before running anything Arachni related.
#
# *DO NOT EDIT* unless you really, really know what you're doing.
#

#
# \$env_root is set by the caller.
#

function version { echo "\$@" | awk -F. '{ printf("%d%d\n", \$1,\$2); }'; }

operating_system=\$(uname -s | awk '{print tolower(\$0)}')

export HOST_PATH=\$PATH

# Only set paths if not already configured.
echo "\$LD_LIBRARY_PATH-\$DYLD_LIBRARY_PATH-\$DYLD_FALLBACK_LIBRARY_PATH" | egrep \$env_root > /dev/null
if [[ \$? -ne 0 ]] ; then
    export PATH; PATH="\$env_root/../bin:\$env_root/usr/bin:\$env_root/gems/bin:\$PATH"
    
    export C_INCLUDE_PATH="\$env_root/usr/include"
    export CPLUS_INCLUDE_PATH="\$C_INCLUDE_PATH"

    # We also set the default paths to make sure that they will be seen by the OS. 
    # There have been issues with Ruby FFI (mostly on OSX 10.11) but why risk it, 
    # set these always just to make sure.
    export LIBRARY_PATH="\$env_root/usr/lib:/usr/lib:/usr/local/lib"
    export LD_LIBRARY_PATH="\$LIBRARY_PATH"

    if [[ "\$operating_system" == "darwin" ]]; then
        # OSX >= 10.11 idiosyncrasy.
        if [[ \`version "\$(sw_vers -productVersion)"\` -gt \$(version "10.10") ]]; then
            export DYLD_FALLBACK_LIBRARY_PATH="\$LIBRARY_PATH"
        else
            export DYLD_LIBRARY_PATH="\$LIBRARY_PATH"
        fi  
    fi  

fi

export RUBY_VERSION; RUBY_VERSION='ruby-2.7.5'
export GEM_HOME; GEM_HOME="\$env_root/gems"
export GEM_PATH; GEM_PATH="\$env_root/gems"
export MY_RUBY_HOME; MY_RUBY_HOME="\$env_root/usr/lib/ruby"
export RUBYLIB; RUBYLIB=\$MY_RUBY_HOME:\$MY_RUBY_HOME/site_ruby/2.7.0:\$MY_RUBY_HOME/2.7.0$platform_lib
export IRBRC; IRBRC="\$env_root/usr/lib/ruby/.irbrc"

# Arachni packages run the system in production.
export RAILS_ENV=production

export ARACHNI_FRAMEWORK_LOGDIR="\$env_root/../logs/framework"
export ARACHNI_WEBUI_LOGDIR="\$env_root/../logs/webui"

EOF
}

get_setenv() {
    cat<<EOF
#!/usr/bin/env bash

env_root="\$(dirname \${BASH_SOURCE[0]})"

writable="
    arachni-ui-web/config/component_cache
    arachni-ui-web/db
    arachni-ui-web/tmp
    ../logs
    home
"

for directory in \$writable; do
    directory="\$env_root/\$directory"

    if [[ ! -w "\$directory" ]]; then
        echo "[ERROR] Directory and subdirectories must be writable: \$directory"
        exit 1
    fi
done

if [[ -s "\$env_root/environment" ]]; then
    source "\$env_root/environment"
else
    echo "ERROR: Missing environment file: '\$env_root/environment" >&2
    exit 1
fi

EOF
}

#
# Provides a wrapper for executables, it basically sets all relevant
# env variables before calling the executable in question.
#
get_wrapper_environment() {
    cat<<EOF
#!/usr/bin/env bash

source "\$(dirname \$0)/readlink_f.sh"
source "\$(dirname "\$(readlink_f "\${0}")")"/../.system/setenv

export HOME="\$env_root/home/arachni"

exec $1

EOF
}


get_shell_script() {
    get_wrapper_environment '; export PS1="\u@\h:\w \033[0;32m\][arachni-shell]\[\033[0m\$ "; bash --noprofile --norc "$@"'
}

get_wrapper_template() {
    get_wrapper_environment "ruby $1 \"\$@\""
}

get_server_script() {
    get_wrapper_template '$GEM_PATH/bin/rackup $env_root/arachni-ui-web/config.ru'
}

get_rake_script() {
    get_wrapper_template '$GEM_PATH/bin/rake -f $env_root/arachni-ui-web/Rakefile'
}

get_rails_runner_script() {
    get_wrapper_template '$env_root/arachni-ui-web/bin/rails runner'
}

#
# Sets the environment, updates rubygems and installs vital gems
#
prepare_ruby() {
    export env_root=$system_path

    echo "  * Generating environment configuration ($env_root/environment)"
    get_ruby_environment > $env_root/environment
    source $env_root/environment

    echo "  * Updating Rubygems"
    $usr_path/bin/gem update --system --no-document 2>> "$logs_path/rubygems" 1>> "$logs_path/rubygems"
    handle_failure "rubygems"

    echo "  * Installing Bundler"
    $usr_path/bin/gem install bundler --no-document  2>> "$logs_path/bundler" 1>> "$logs_path/bundler"
    handle_failure "bundler"
}

install_chrome() {

  if [[ "Darwin" == "$(uname)" ]]; then
      install_chrome_mac
  else
      install_chrome_linux
  fi

}

install_chrome_mac() {
    download https://dl.google.com/chrome/mac/universal/stable/GGRO/googlechrome.dmg "-O $archives_path/chrome.dmg"

    rm -rf $build_path/tmp/chrome-data
    rm -rf "$system_path/usr/bin/Google Chrome.app/"

    mkdir $build_path/tmp/chrome-data
    cd $build_path/tmp/chrome-data

    7zz x "$archives_path/chrome.dmg" 2>> "$logs_path/chrome" 1>> "$logs_path/chrome"
    cp -R "Google Chrome/Google Chrome.app" $system_path/usr/bin/
    handle_failure "chrome"

    cd - 2>> "$logs_path/chrome" 1>> "$logs_path/chrome"

    version_details=($($system_path/usr/bin/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --version))

    download "https://chromedriver.storage.googleapis.com/${version_details[2]}/chromedriver_mac64.zip" "-O $archives_path/chromedriver.zip"
#    download "https://chromedriver.storage.googleapis.com/98.0.4758.102/chromedriver_mac64.zip" "-O $archives_path/chromedriver.zip"
    unzip -o $archives_path/chromedriver.zip -d $system_path/usr/bin/  2>> "$logs_path/chromedriver" 1>> "$logs_path/chromedriver"
    handle_failure "chromedriver"
}

install_chrome_linux() {
    download https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb "-O $archives_path/chrome.deb"

    rm -rf $build_path/tmp/chrome-data
    mkdir $build_path/tmp/chrome-data
    cd $build_path/tmp/chrome-data

    ar x "$archives_path/chrome.deb" 2>> "$logs_path/chrome" 1>> "$logs_path/chrome"
    tar xvf data.tar.xz  2>> "$logs_path/chrome" 1>> "$logs_path/chrome"

    rm data.tar.xz
    rm control.tar.xz
    rm debian-binary

    rsync -a . $system_path/

    cd - 2>> "$logs_path/chrome" 1>> "$logs_path/chrome"

    # Remove faulty symlink.
    rm -f $system_path/usr/bin/google-chrome-stable
    rm -f $system_path/usr/bin/google-chrome
    rm -f $system_path/usr/bin/chrome

    ln -s ../../opt/google/chrome/google-chrome $system_path/usr/bin/google-chrome-stable
    ln -s ../../opt/google/chrome/google-chrome $system_path/usr/bin/google-chrome
    ln -s ../../opt/google/chrome/google-chrome $system_path/usr/bin/chrome

    version_details=($($system_path/usr/bin/google-chrome --version))

    download "https://chromedriver.storage.googleapis.com/${version_details[2]}/chromedriver_linux64.zip" "-O $archives_path/chromedriver.zip"
    unzip -o $archives_path/chromedriver.zip -d $system_path/usr/bin/  2>> "$logs_path/chromedriver" 1>> "$logs_path/chromedriver"
}

download_arachni() {
    # The Arachni Web interface archive needs to be stored under $system_path
    # because it needs to be preserved, it is our app after all.
    rm "$archives_path/arachni-ui-web.tar.gz" &> /dev/null
    download $arachni_tarball_url "-O $archives_path/arachni-ui-web.tar.gz"
    handle_failure "arachni-ui-web"
    extract_archive "arachni-ui-web" $system_path

    # GitHub may append the git ref or branch to the folder name, strip it.
    mv $system_path/arachni-ui-web* $system_path/arachni-ui-web

}

#
# Installs the Arachni Web User Interface which in turn pulls in the Framework
# as a dependency, that way we kill two birds with one package.
#
install_arachni() {

    $gem_path/bin/bundle config build.puma --with-cflags="-Wno-error=implicit-function-declaration"
    $gem_path/bin/bundle config --local build.sassc --disable-march-tune-native

    echo "  * Installing bundle"

    cd $system_path/arachni-ui-web

    $gem_path/bin/bundle install --binstubs 2>> "$logs_path/arachni-ui-web" 1>> "$logs_path/arachni-ui-web"
    handle_failure "arachni-ui-web"

    # If we don't do this Rails 4 will keep printing annoying messages when using the runner
    # or console.
    # yes | $gem_path/bin/bundle exec $gem_path/bin/rake rails:update:bin 2>> "$logs_path/arachni-ui-web" 1>> "$logs_path/arachni-ui-web"
    # handle_failure "arachni-ui-web"

    echo "  * Precompiling assets"
    $gem_path/bin/bundle exec $gem_path/bin/rake assets:precompile 2>> "$logs_path/arachni-ui-web" 1>> "$logs_path/arachni-ui-web"
    handle_failure "arachni-ui-web"

    echo "  * Setting-up the database"
    $gem_path/bin/bundle exec $gem_path/bin/rake db:migrate 2>> "$logs_path/arachni-ui-web" 1>> "$logs_path/arachni-ui-web"
    handle_failure "arachni-ui-web"
    DISABLE_DATABASE_ENVIRONMENT_CHECK=1 $gem_path/bin/bundle exec $gem_path/bin/rake db:setup 2>> "$logs_path/arachni-ui-web" 1>> "$logs_path/arachni-ui-web"
    handle_failure "arachni-ui-web"

    echo "  * Writing full version to VERSION file"

    # Needed by build_and_package.sh to figure out the release version and it's
    # nice to have anyways.
    $gem_path/bin/bundle exec $gem_path/bin/rake version:full > "$root/VERSION"
    handle_failure "arachni-ui-web"
}

install_bin_wrappers() {
    cp "$scriptdir/lib/readlink_f.sh" "$root/bin/"

    get_setenv > "$root/.system/setenv"
    chmod +x "$root/.system/setenv"

    web_executables="
        create_user
        change_password
        import
        scan_import
    "
    for executable in $web_executables; do
        get_wrapper_template "\$env_root/arachni-ui-web/script/$executable" > "$root/bin/arachni_web_$executable"
        chmod +x "$root/bin/arachni_web_$executable"
        echo "  * $root/bin/arachni_web_$executable"
    done

    get_server_script > "$root/bin/arachni_web"
    chmod +x "$root/bin/arachni_web"
    echo "  * $root/bin/arachni_web"

    get_rails_runner_script > "$root/bin/arachni_web_script"
    chmod +x "$root/bin/arachni_web_script"
    echo "  * $root/bin/arachni_web_script"

    get_rake_script > "$root/bin/arachni_web_task"
    chmod +x "$root/bin/arachni_web_task"
    echo "  * $root/bin/arachni_web_task"

    get_shell_script > "$root/bin/arachni_shell"
    chmod +x "$root/bin/arachni_shell"
    echo "  * $root/bin/arachni_shell"


    cd $env_root/arachni-ui-web/bin
    for bin in arachni*; do
        echo "  * $root/bin/$bin => $env_root/arachni-ui-web/bin/$bin"
        get_wrapper_template "\$env_root/arachni-ui-web/bin/$bin" > "$root/bin/$bin"
        chmod +x "$root/bin/$bin"
    done
    cd - > /dev/null
}

echo
echo '# (1/7) Creating directories'
echo '---------------------------------'
setup_dirs

echo
echo '# (2/7) Installing dependencies'
echo '-----------------------------------'
install_libs

echo
echo '# (3/7) Installing Chrome'
echo '-----------------------------------'
install_chrome

if [[ ! -d $clean_build ]] || [[ $update_clean_dir == true ]]; then
    mkdir -p $clean_build/.system/
    echo "==== Backing up clean build directory ($clean_build)."
    cp -R $usr_path $clean_build/.system/
fi

echo
echo '# (4/7) Downloading Arachni'
echo '-------------------------------------------'
download_arachni

echo
echo '# (5/7) Preparing the Ruby environment'
echo '-------------------------------------------'
prepare_ruby

echo
echo '# (6/7) Installing Arachni'
echo '-------------------------------'
install_arachni

echo
echo '# (7/7) Installing bin wrappers'
echo '------------------------------------'
install_bin_wrappers

echo
echo '# Cleaning up'
echo '----------------'
echo "  * Removing build resources"
rm -rf $build_path

if [[ environment == 'development' ]]; then
    echo "  * Removing development headers"
    rm -rf $usr_path/include/*
fi

echo "  * Removing docs"
rm -rf $usr_path/share/*
rm -rf $gem_path/doc/*

echo "  * Clearing GEM cache"
rm -rf $gem_path/cache/*

cp "$scriptdir/templates/README.tpl" "$root/README"
cp "$scriptdir/templates/LICENSE.tpl" "$root/LICENSE"
cp "$scriptdir/templates/TROUBLESHOOTING.tpl" "$root/TROUBLESHOOTING"

echo "  * Adjusting shebangs"
if [[ `uname` == "Darwin" ]]; then
    find $env_root/ -type f -exec sed -i '' 's/#!\/.*\/ruby/#!\/usr\/bin\/env ruby/g' {} \; 2>> /dev/null 1>> /dev/null
else
    find $env_root/ -type f -exec sed -i 's/#!\/.*\/ruby/#!\/usr\/bin\/env ruby/g' {} \;
fi

echo
cat<<EOF
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Build completed successfully!

You can add '$root/bin' to your path in order to be able to access the Arachni
executables from anywhere:

    echo 'export PATH=$root/bin:\$PATH' >> ~/.bash_profile
    source ~/.bash_profile

Useful resources:
    * Homepage           - http://arachni-scanner.com
    * Blog               - http://arachni-scanner.com/blog
    * Documentation      - http://arachni-scanner.com/wiki
    * Support            - http://support.arachni-scanner.com
    * GitHub page        - http://github.com/Arachni/arachni
    * Code Documentation - http://rubydoc.info/github/Arachni/arachni
    * Author             - Tasos "Zapotek" Laskos (http://twitter.com/Zap0tek)
    * Twitter            - http://twitter.com/ArachniScanner
    * Copyright          - 2010-2022 Ecsypno

Have fun ;)

Cheers,
The Arachni team.

EOF
