#!/bin/bash

SCRIPT_ROOT=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
SRC_ROOT=$SCRIPT_ROOT/src
BUILD_ROOT=$SRC_ROOT/build

. /etc/os-release

GDB_VER=11.2
GDB_SRC=gdb-${GDB_VER}
GDB_PREFIX=/opt/zach/${GDB_SRC}
GDB_OPT=(
    --prefix=${GDB_PREFIX}
    --enable-tui
    --with-python
)

install_dep() {
    case $ID in
        ubuntu|debian )
            echo "Install on $ID"
            sudo apt update
            sudo apt install -y build-essential texinfo bison flex
            ;;
        * )
            echo "Unsupport $ID"
            ;;
    esac
    echo "Install build deps done"
}

install_bin() {
    target=/usr/local/bin
    echo "Install gdb bin to $target"
    sudo ln -sfvT $GDB_PREFIX/bin/gdb $target/gdb
    sudo ln -sfvT $GDB_PREFIX/bin/gdbtui $target/gdbtui
    sudo ln -sfvT $GDB_PREFIX/bin/gdbserver $target/gdbserver
    echo "Install bin done"
}

build() {
    echo "Build run autogen.sh"
    echo "Build ${GDB_SRC}"
    mkdir -p $BUILD_ROOT
    pushd $BUILD_ROOT
    $SRC_ROOT/configure ${GDB_OPT[@]}
    make -j8
    sudo make install
    install_bin
    popd
    echo "Build done"
}

clean() {
    pushd $SCRIPT_ROOT
    git clean -dfx
    popd
    echo "Clean done"
}

usage() {
    app=$(basename $0)
    cat <<EOF
Usage: $app {dep|-d|-t|build|-b|bin|clean|-c|all|-a}
EOF
}

case $1 in
    dep|-d )
        install_dep
        ;;
    build|-b )
        build
        ;;
    bin )
        install_bin
        ;;
    clean|-c )
        clean
        ;;
    all|-a )
        install_dep
        build
        clean
        ;;
    * )
        usage
        ;;
esac
