# SPDX-License-Identifier: BSD-3-Clause
# Copyright (c) 2026 - Present Romain Augier
# All rights reserved.

include(CheckCXXCompilerFlag)

# Architecture specific optimization flags, shared by gcc and clang
function(get_arch_compile_options out_var)
    set(arch_options)

    if(CHRONOS_ARCH_X86_64 OR CHRONOS_ARCH_X86)
        list(APPEND arch_options -mavx2 -mfma)
    elseif(CHRONOS_ARCH_AARCH64)
        # NEON is mandatory in armv8-a, let the compiler use the extensions of the build machine.
        # CMAKE_CROSSCOMPILING is false when targeting arm64 from an intel mac with CMAKE_OSX_ARCHITECTURES,
        # hence the host processor check
        string(TOLOWER "${CMAKE_HOST_SYSTEM_PROCESSOR}" host_processor)

        if(NOT CMAKE_CROSSCOMPILING AND host_processor MATCHES "^(aarch64|arm64)$")
            check_cxx_compiler_flag("-mcpu=native" HAS_MCPU_NATIVE)

            if(HAS_MCPU_NATIVE)
                list(APPEND arch_options -mcpu=native)
            endif()
        endif()
    endif()

    set(${out_var} ${arch_options} PARENT_SCOPE)
endfunction()

function(add_sanitizer target_name sanitizer)
    target_compile_options(${target_name} PRIVATE $<$<CONFIG:Debug,RelWithDebInfo>:-fsanitize=${sanitizer} -fno-omit-frame-pointer>)
    target_link_options(${target_name} PRIVATE $<$<CONFIG:Debug,RelWithDebInfo>:-fsanitize=${sanitizer}>)
endfunction()

function(set_target_options target_name)
    # MSVC is also true for clang-cl, which takes msvc style flags
    if(MSVC)
        if(CHRONOS_ARCH_X86_64 OR CHRONOS_ARCH_X86)
            include(find_avx)
        else()
            # No /arch: flag is needed for arm64, NEON is always available
            set(AVX_FLAGS)
        endif()

        if(ADDRSAN)
            target_compile_options(${target_name} PRIVATE $<$<CONFIG:Debug,RelWithDebInfo>:/fsanitize=address>)
        endif()

        # 4710 is "Function not inlined", we don't care it pollutes more than tells useful information about the code
        # 5045 is "Compiler will insert Spectre mitigation for memory load if /Qspectre switch specified", again we don't care
        # 4324 is "structure was padded due to alignment specifier", again we don't care
        # 4146 is "unary minus operator applied to unsigned type", again we don't care
        set(COMPILE_OPTIONS
            /W4 /wd4710 /wd5045 /wd4324 /wd4146
            /utf-8
            /Zi
            ${AVX_FLAGS}
            $<$<CONFIG:Release,RelWithDebInfo>:/O2 /GF /Ot /GT /GL /Oi>
            $<$<CONFIG:Debug>:/Ob0>)

        # Frame pointer omission only exists on x86
        if(CHRONOS_ARCH_X86)
            list(APPEND COMPILE_OPTIONS $<$<CONFIG:Release,RelWithDebInfo>:/Oy>)
        endif()

        target_compile_options(${target_name} PRIVATE ${COMPILE_OPTIONS})

        # /GL objects need /LTCG
        # 4300 is "ignoring '/INCREMENTAL' because input module contains ASAN metadata", and we do not care
        # 4075 is "ignoring '/INCREMENTAL' due to '/PROFILE' specification", again we do not care
        target_link_options(${target_name} PRIVATE
                            /ignore:4075 /ignore:4300
                            $<$<CONFIG:Release,RelWithDebInfo>:/LTCG>
                            $<$<CONFIG:Debug,RelWithDebInfo>:/PROFILE /OPT:NOREF>)
    elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang|GNU")
        # AppleClang is a distinct compiler id, MATCHES catches Clang and AppleClang
        get_arch_compile_options(ARCH_COMPILE_OPTIONS)

        set(COMPILE_OPTIONS
            -pipe
            -Wall
            -pedantic-errors
            ${ARCH_COMPILE_OPTIONS}
            $<$<CONFIG:Release,RelWithDebInfo>:-O3>
            $<$<CONFIG:Release,RelWithDebInfo>:-D_FORTIFY_SOURCE=2>)

        # -mveclibabi is gcc and x86 only
        if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" AND (CHRONOS_ARCH_X86_64 OR CHRONOS_ARCH_X86))
            list(APPEND COMPILE_OPTIONS -mveclibabi=svml)
        endif()

        if(VECTORIZE_REPORT)
            if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
                list(APPEND COMPILE_OPTIONS $<$<CONFIG:Release,RelWithDebInfo>:-fopt-info-vec-optimized>)
            else()
                list(APPEND COMPILE_OPTIONS $<$<CONFIG:Release,RelWithDebInfo>:-Rpass=loop-vectorize>)
            endif()
        endif()

        target_compile_options(${target_name} PRIVATE ${COMPILE_OPTIONS})

        if(ADDRSAN)
            add_sanitizer(${target_name} address)
        endif()

        if(LEAKSAN)
            if(APPLE)
                # Not implemented on darwin, AddressSanitizer has its own leak detection there
                message(WARNING "LeakSanitizer is not available on macOS, ignoring LEAKSAN")
            else()
                add_sanitizer(${target_name} leak)
            endif()
        endif()

        if(UBSAN)
            add_sanitizer(${target_name} undefined)
        endif()

        if(THREADSAN)
            add_sanitizer(${target_name} thread)
        endif()

        if(COVERAGE)
            target_compile_options(${target_name} PRIVATE --coverage -O0 -g)
            target_link_options(${target_name} PRIVATE --coverage)
        endif()
    else()
        message(WARNING "Unsupported compiler \"${CMAKE_CXX_COMPILER_ID}\", no options set for ${target_name}")
    endif()

    # Provides the macro definition DEBUG_BUILD
    target_compile_definitions(${target_name} PRIVATE $<$<CONFIG:Debug>:DEBUG_BUILD>)
endfunction()
