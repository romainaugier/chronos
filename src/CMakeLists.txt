# SPDX-License-Identifier: BSD-3-Clause
# Copyright (c) 2026 - Present Romain Augier
# All rights reserved.

include(GNUInstallDirs)
include(target_options)

file(GLOB_RECURSE src_files CONFIGURE_DEPENDS *.cpp)

add_library(${PROJECT_NAME} SHARED ${src_files})

set_target_properties(${PROJECT_NAME} PROPERTIES
                      PREFIX ""
                      DEBUG_POSTFIX "d"
                      CXX_STANDARD 17
                      CXX_STANDARD_REQUIRED ON)

set_target_options(${PROJECT_NAME})

# PRIVATE: consumers must see CHRONOS_API as an import
target_compile_definitions(${PROJECT_NAME} PRIVATE CHRONOS_BUILD_SHARED)

if(PROJECT_VERSION_TWEAK)
    set(CHRONOS_VERSION_REVISION ${PROJECT_VERSION_TWEAK})
else()
    set(CHRONOS_VERSION_REVISION 0)
endif()

target_compile_definitions(${PROJECT_NAME}
                           PUBLIC
                           CHRONOS_VERSION_MAJOR=${PROJECT_VERSION_MAJOR}
                           CHRONOS_VERSION_MINOR=${PROJECT_VERSION_MINOR}
                           CHRONOS_VERSION_PATCH=${PROJECT_VERSION_PATCH}
                           CHRONOS_VERSION_REVISION=${CHRONOS_VERSION_REVISION})

target_link_libraries(${PROJECT_NAME} PUBLIC stdromano::stdromano)

target_include_directories(${PROJECT_NAME}
                           PUBLIC
                           $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
                           $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)

install(
    TARGETS ${PROJECT_NAME}
    EXPORT "${PROJECT_NAME}Targets"
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

install(
    DIRECTORY "${PROJECT_SOURCE_DIR}/include/${PROJECT_NAME}"
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    FILES_MATCHING PATTERN "*.hpp"
)

install(
    EXPORT "${PROJECT_NAME}Targets"
    FILE "${PROJECT_NAME}Targets.cmake"
    NAMESPACE "${PROJECT_NAME}::"
    DESTINATION cmake
)

include(CMakePackageConfigHelpers)

configure_package_config_file(
    "${PROJECT_SOURCE_DIR}/${PROJECT_NAME}Config.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
    PATH_VARS CMAKE_INSTALL_INCLUDEDIR CMAKE_INSTALL_BINDIR
    INSTALL_DESTINATION cmake
)

write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY AnyNewerVersion
)

install(
    FILES "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
          "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
    DESTINATION cmake
)
