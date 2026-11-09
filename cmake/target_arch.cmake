# SPDX-License-Identifier: BSD-3-Clause
# Copyright (c) 2026 - Present Romain Augier
# All rights reserved.

# Target architecture detection, must be included after project().
# Sets CHRONOS_TARGET_ARCH and one of CHRONOS_ARCH_{X86_64,X86,AARCH64,AARCH32}

if(CMAKE_OSX_ARCHITECTURES)
    list(LENGTH CMAKE_OSX_ARCHITECTURES _osx_arch_count)

    if(_osx_arch_count GREATER 1)
        # One set of flags cannot target all the slices of a universal binary
        set(CHRONOS_TARGET_ARCH "universal")
    else()
        set(CHRONOS_TARGET_ARCH "${CMAKE_OSX_ARCHITECTURES}")
    endif()
elseif(MSVC AND CMAKE_CXX_COMPILER_ARCHITECTURE_ID)
    # With the Visual Studio generators CMAKE_SYSTEM_PROCESSOR is the host (-A ARM64 from an x64 machine)
    set(CHRONOS_TARGET_ARCH "${CMAKE_CXX_COMPILER_ARCHITECTURE_ID}")
else()
    set(CHRONOS_TARGET_ARCH "${CMAKE_SYSTEM_PROCESSOR}")
endif()

string(TOLOWER "${CHRONOS_TARGET_ARCH}" CHRONOS_TARGET_ARCH)

if(CHRONOS_TARGET_ARCH MATCHES "^(x86_64|amd64|x64)$")
    set(CHRONOS_ARCH_X86_64 ON)
elseif(CHRONOS_TARGET_ARCH MATCHES "^(aarch64|arm64|arm64ec|armv8.*)$")
    set(CHRONOS_ARCH_AARCH64 ON)
elseif(CHRONOS_TARGET_ARCH MATCHES "^(i.86|x86)$")
    set(CHRONOS_ARCH_X86 ON)
elseif(CHRONOS_TARGET_ARCH MATCHES "^arm")
    set(CHRONOS_ARCH_AARCH32 ON)
elseif(NOT CHRONOS_TARGET_ARCH STREQUAL "universal")
    message(WARNING "Unknown target architecture \"${CHRONOS_TARGET_ARCH}\", building without architecture specific flags")
endif()

message(STATUS "chronos target architecture: ${CHRONOS_TARGET_ARCH}")
