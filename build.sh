#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause
# Copyright (c) 2026 - Present Romain Augier
# All rights reserved.

BUILDTYPE="Release"
RUNTESTS=0
REMOVEOLDDIR=0
EXPORTCOMPILECOMMANDS=0
VERSION="0.0.0"
INSTALL=0
INSTALLDIR="$PWD/install"
THREADSAN=0
UBSAN=0
ADDRSAN=0
LEAKSAN=0
COVERAGE=0
VECTORIZE_REPORT=0
REBUILDSTDROMANO=0
VCPKGPATH=""
STDROMANO_DIR="$PWD/ext/stdromano"

# Little function to log an information message to the console
log_info()
{
    echo "[INFO] : $1"
}

# Little function to log a warning message to the console
log_warning()
{
    echo "[WARNING] : $1"
}

# Little function to log an error message to the console
log_error()
{
    echo "[ERROR] : $1"
}

# Little function to parse command line arguments
parse_args()
{
    case "$1" in
        --debug) BUILDTYPE="Debug" ;;
        --reldebug) BUILDTYPE="RelWithDebInfo" ;;
        --tests) RUNTESTS=1 ;;
        --clean) REMOVEOLDDIR=1 ;;
        --install) INSTALL=1 ;;
        --threadsan) THREADSAN=1 ;;
        --ubsan) UBSAN=1 ;;
        --addrsan) ADDRSAN=1 ;;
        --leaksan) LEAKSAN=1 ;;
        --coverage) COVERAGE=1 ;;
        --vectorize-report) VECTORIZE_REPORT=1 ;;
        --export-compile-commands) EXPORTCOMPILECOMMANDS=1 ;;
        --rebuild-stdromano) REBUILDSTDROMANO=1 ;;
        --version:*)
            VERSION="${1#*:}"
            log_info "Version specified by user: $VERSION"
            ;;
        --installdir:*)
            INSTALLDIR="${1#*:}"
            log_info "Install directory specified by user: $INSTALLDIR"
            ;;
        --vcpkgpath:*)
            VCPKGPATH="${1#*:}"
            log_info "Vcpkg path specified by user: $VCPKGPATH"
            ;;
        *) log_warning "Unknown argument: $1" ;;
    esac
}

# nproc does not exist on macOS and on the bsds
num_procs()
{
    if command -v nproc > /dev/null 2>&1; then
        nproc
    else
        sysctl -n hw.ncpu
    fi
}

# stdromano is built with the same build type and sanitizers as chronos, and installed in
# ext/stdromano/install. A stamp per variant (debug/release) records the flags of the install
build_stdromano()
{
    if [[ ! -f "$STDROMANO_DIR/build.sh" ]]; then
        log_error "ext/stdromano is empty, run: git submodule update --init --recursive"
        return 1
    fi

    local variant="release"
    local flags=""

    case "$BUILDTYPE" in
        Debug) variant="debug"; flags="--debug" ;;
        RelWithDebInfo) flags="--reldebug" ;;
    esac

    [[ $ADDRSAN -eq 1 ]] && flags="$flags --addrsan"
    [[ $LEAKSAN -eq 1 ]] && flags="$flags --leaksan"
    [[ $UBSAN -eq 1 ]] && flags="$flags --ubsan"
    [[ $THREADSAN -eq 1 ]] && flags="$flags --threadsan"

    local stamp="$STDROMANO_DIR/install/chronos_$variant.stamp"

    if [[ $REBUILDSTDROMANO -eq 0 && -f "$stamp" && "$(cat "$stamp")" == "$flags" ]]; then
        log_info "stdromano ($variant) is up to date"
        return 0
    fi

    log_info "Building stdromano ($variant, flags:${flags:- none})"

    local vcpkg_flag=""
    [[ -n "$VCPKGPATH" ]] && vcpkg_flag="--vcpkgpath:$VCPKGPATH"

    (cd "$STDROMANO_DIR" && ./build.sh --install $flags $vcpkg_flag) || return 1

    echo "$flags" > "$stamp"
}

log_info "Building chronos"

for arg in "$@"
do
    parse_args "$arg"
done

if [[ $THREADSAN -eq 1 && ( $ADDRSAN -eq 1 || $LEAKSAN -eq 1 ) ]]; then
    log_error "ThreadSanitizer cannot be combined with AddressSanitizer or LeakSanitizer"
    exit 1
fi

log_info "Build type: $BUILDTYPE"
log_info "Build version: $VERSION"

if ! build_stdromano; then
    log_error "Error during the stdromano build"
    exit 1
fi

if [[ -d "build" && $REMOVEOLDDIR -eq 1 ]]; then
    log_info "Removing old build directory"
    rm -rf build
fi

if [[ -d "$INSTALLDIR" && $REMOVEOLDDIR -eq 1 ]]; then
    log_info "Removing old install directory"
    rm -rf "$INSTALLDIR"
fi

cmake -S . -B build -DRUN_TESTS=$RUNTESTS \
                    -DCMAKE_EXPORT_COMPILE_COMMANDS=$EXPORTCOMPILECOMMANDS \
                    -DCMAKE_BUILD_TYPE=$BUILDTYPE \
                    -DVERSION=$VERSION \
                    -DTHREADSAN=$THREADSAN \
                    -DUBSAN=$UBSAN \
                    -DADDRSAN=$ADDRSAN \
                    -DLEAKSAN=$LEAKSAN \
                    -DCOVERAGE=$COVERAGE \
                    -DVECTORIZE_REPORT=$VECTORIZE_REPORT

if [[ $? -ne 0 ]]; then
    log_error "Error during CMake configuration"
    exit 1
fi

cd build

cmake --build . --config $BUILDTYPE -j $(num_procs)

if [[ $? -ne 0 ]]; then
    log_error "Error during CMake build"
    cd ..
    exit 1
fi

if [[ $RUNTESTS -eq 1 ]]; then
    ctest --output-on-failure -C $BUILDTYPE

    if [[ $? -ne 0 ]]; then
        log_error "Error during CMake testing"
        cd ..
        exit 1
    fi
fi

if [[ $INSTALL -eq 1 ]]; then
    cmake --install . --config $BUILDTYPE --prefix "$INSTALLDIR"

    if [[ $? -ne 0 ]]; then
        log_error "Error during CMake installation"
        cd ..
        exit 1
    fi
fi

cd ..

if [[ $EXPORTCOMPILECOMMANDS -eq 1 ]]; then
    cp ./build/compile_commands.json ./compile_commands.json
    log_info "Copied compile_commands.json to root directory"
fi
