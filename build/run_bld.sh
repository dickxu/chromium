#!/bin/sh
ROOT=`pwd`
CHROME=$ROOT/src
OS=`uname`


function gsync() {
    gfile=$CHROME/../.gclient
    #[ -f $gfile ] && return
    opts="--unmanaged --deps-file=.DEPS.git"
    cd $CHROME/.. && gclient config $opts https://chromium.googlesource.com/chromium/src.git
}

function initenv() {
    GYP_DEFINES=""
    if [ $OS = "Darwin" ]; then
        #sudo sysctl -w kern.maxproc=2500
        #sudo sysctl -w kern.maxprocperuid=2500
        export GYP_GENERATORS="ninja,xcode-ninja"
        export GYP_GENERATOR_FLAGS="xcode_ninja_main_gyp=build/ninja/all.ninja.gyp"
        #GYP_DEFINES+=" clang=0" 
    elif [ $OS = "Linux" ]; then
        export GYP_GENERATORS="ninja"
        GYP_DEFINES+=" clang=1" 
        GYP_DEFINES+=" disable_nacl=1"
        #GYP_DEFINES+=" clang_use_chrome_plugins=0"
    fi

    GYP_DEFINES+=" fastbuild=1"
    GYP_DEFINES+=" target_arch=x64"
    GYP_DEFINES+=" CONFIGURATION_NAME=Debug"
    GYP_DEFINES+=" ffmpeg_branding=Chrome proprietary_codecs=1"
    export GYP_DEFINES="$GYP_DEFINES"
}

function prepare() {
    cd $CHROME/../ && gclient sync
    cd $CHROME/../ && gclient runhooks --deps=$OS
    cd $CHROME && build/gyp_chromium
}

function update() { 
    echo
    #cd $CHROME && build/install-build-deps.sh
    # for linux without plugin
    #cd $CHROME && tools/clang/scripts/update.sh --force-local-build --without-android
    # for mac/ios
    #cd $CHROME && tools/clang/scripts/update.sh
}

function build() {
    cd $CHROME && ninja -C out/Debug chrome -j16
    #cd $CHROME && ninja -C out/Debug blink -j16
}



gsync
initenv
#prepare
#update
build

exit 0
