# SPDX-License-Identifier: BSD-3-Clause
# Copyright (c) 2026 - Present Romain Augier
# All rights reserved.

include(target_options)

file(GLOB_RECURSE TEST_FILES CONFIGURE_DEPENDS *.cpp)

# The msvc asan runtime has to be next to the executables
if(MSVC AND ADDRSAN)
    get_filename_component(CL_DIR ${CMAKE_CXX_COMPILER} DIRECTORY)

    if(CHRONOS_ARCH_X86)
        set(ASAN_DLL "${CL_DIR}/clang_rt.asan_dynamic-i386.dll")
    elseif(CHRONOS_ARCH_AARCH64)
        set(ASAN_DLL "${CL_DIR}/clang_rt.asan_dynamic-aarch64.dll")
    else()
        set(ASAN_DLL "${CL_DIR}/clang_rt.asan_dynamic-x86_64.dll")
    endif()

    if(NOT EXISTS "${ASAN_DLL}")
        message(WARNING "Cannot find the asan runtime (${ASAN_DLL}), the tests may not start")
        unset(ASAN_DLL)
    endif()
endif()

foreach(test_file ${TEST_FILES})
    get_filename_component(TESTNAME ${test_file} NAME_WLE)
    message(STATUS "Adding chronos test : ${TESTNAME}")

    add_executable(${TESTNAME} ${test_file})
    set_target_properties(${TESTNAME} PROPERTIES
                          CXX_STANDARD 17
                          CXX_STANDARD_REQUIRED ON)
    set_target_options(${TESTNAME})
    target_link_libraries(${TESTNAME} PRIVATE ${PROJECT_NAME})

    add_test(NAME ${TESTNAME} COMMAND ${TESTNAME})

    if(WIN32)
        # The library dll (and its dependencies) next to the test
        add_custom_command(
            TARGET ${TESTNAME} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_RUNTIME_DLLS:${TESTNAME}> $<TARGET_FILE_DIR:${TESTNAME}>
            COMMAND_EXPAND_LISTS
        )
    endif()

    if(MSVC)
        # The library pdb, for the stack traces
        add_custom_command(
            TARGET ${TESTNAME} POST_BUILD
            COMMAND "$<$<CONFIG:Debug,RelWithDebInfo>:${CMAKE_COMMAND};-E;copy_if_different;$<TARGET_PDB_FILE:${PROJECT_NAME}>;$<TARGET_FILE_DIR:${TESTNAME}>>"
            COMMAND_EXPAND_LISTS
        )

        if(ASAN_DLL)
            add_custom_command(
                TARGET ${TESTNAME} POST_BUILD
                COMMAND "$<$<CONFIG:Debug,RelWithDebInfo>:${CMAKE_COMMAND};-E;copy_if_different;${ASAN_DLL};$<TARGET_FILE_DIR:${TESTNAME}>>"
                COMMAND_EXPAND_LISTS
            )
        endif()
    endif()
endforeach()
