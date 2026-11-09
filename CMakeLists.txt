# SPDX-License-Identifier: BSD-3-Clause
# Copyright (c) 2026 - Present Romain Augier
# All rights reserved.

# 3.21 for $<TARGET_RUNTIME_DLLS> (3.19 for $<CONFIG:A,B>)
cmake_minimum_required(VERSION 3.21)

if(NOT DEFINED VERSION OR VERSION STREQUAL "")
    set(VERSION "0.0.0")
endif()

project(chronos VERSION ${VERSION} LANGUAGES CXX)

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")

include(CMakePrintHelpers)
include(target_arch)

set(CMAKE_VERBOSE_MAKEFILE ON)

option(RUN_TESTS "Build and run the tests" OFF)
option(ADDRSAN "Build with AddressSanitizer (Debug and RelWithDebInfo)" OFF)
option(LEAKSAN "Build with LeakSanitizer (Debug and RelWithDebInfo, not available on macOS)" OFF)
option(UBSAN "Build with UndefinedBehaviorSanitizer (Debug and RelWithDebInfo)" OFF)
option(THREADSAN "Build with ThreadSanitizer (Debug and RelWithDebInfo)" OFF)
option(COVERAGE "Enable code coverage instrumentation (GCC/Clang)" OFF)
option(VECTORIZE_REPORT "Print the loops vectorized by the compiler (GCC/Clang, Release and RelWithDebInfo)" OFF)

if(THREADSAN AND (ADDRSAN OR LEAKSAN))
    message(FATAL_ERROR "ThreadSanitizer cannot be combined with AddressSanitizer or LeakSanitizer")
endif()

# stdromano, built and installed in ext/stdromano/install by build.sh / build.bat
set(stdromano_DIR "${PROJECT_SOURCE_DIR}/ext/stdromano/install/cmake" CACHE PATH "Directory containing stdromanoConfig.cmake")

if(NOT EXISTS "${stdromano_DIR}/stdromanoConfig.cmake")
    message(FATAL_ERROR "Cannot find stdromano in ${stdromano_DIR}, build with build.sh / build.bat "
                        "(git submodule update --init --recursive first) or set stdromano_DIR to an existing install")
endif()

find_package(stdromano CONFIG REQUIRED)

if(RUN_TESTS)
    message(STATUS "RUN_TESTS enabled, building and running tests")
    enable_testing()
endif()

add_subdirectory(src)

if(RUN_TESTS)
    add_subdirectory(tests)
endif()
