cmake_minimum_required(VERSION 3.0)
include (CMakeParseArguments)



# usage example:
# project(mylib VERSION 1.0 LANGUAGES CXX)
# 
# set(INTERFACE interface/mylib_exports.hpp interface/mylib.hpp)
# set(HEADERS detail/mylib_private.hpp)
# set(SOURCES detail/mylib.cpp detail/mylib_private.cpp)
# set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/install/${CMAKE_PROJECT_NAME}_${PROJECT_VERSION})
# set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake) # this is for find this module (example this module in ${CMAKE_CURRENT_SOURCE_DIR}/cmake folder)
# include(install_library)
# 
# add_library(${PROJECT_NAME} SHARED ${INTERFACE} ${HEADERS} ${SOURCES})
# target_link_libraries(${PROJECT_NAME} PRIVATE example_dependency)
# target_compile_definitions(${PROJECT_NAME} PRIVATE mylib_LIBRARY)
# 
# install_library(NAME ${PROJECT_NAME}            - install target for library
#                 INTERFACE_DIR interface         - interface headers directory
#                 INTERFACE_FILES INTERFACE       - interface headers variable
#                 INTERFACE_INSTALL_DIR mylib     - interface target directory in final include folder (example: include/mylib)
#                 NAMESPACE lib)                  - namespace for library (example: target_link_libraries(... lib::mylib ...))
#
#
# after installing final directory structure looks like for according this example:
# mylib_1.0               # root library install dir
# L  include
# |   L  mylib
# |       L   mylib_exports.hpp
# |       L   mylib.hpp
# L  lib
#    L   mylib_x64
#    |   L   cmake        # cmake files for find_package and target_link_libraries
#    |   L   mylib1.dll
#    |   L   mylib1d.dll
#    |   
#    L   mylib_x86
#        L   cmake        # cmake files for find_package and target_link_libraries
#        L   mylib1.dll
#        L   mylib1d.dll
#    
# 

function(install_library)
set (options)
set (oneValueArgs
    NAME
    INTERFACE_FILES
    INTERFACE_DIR
    INTERFACE_INSTALL_DIR
    NAMESPACE
    )
set (multiValueArgs)
cmake_parse_arguments(PROJECT "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

set_target_properties(${PROJECT_NAME} PROPERTIES OUTPUT_NAME ${PROJECT_NAME}${PROJECT_VERSION_MAJOR})

if (NOT DEFINED PROJECT_INTERFACE_DIR OR PROJECT_INTERFACE_DIR STREQUAL "")
    set(PROJECT_INTERFACE_DIR "interface" CACHE PATH "" FORCE)
endif()

if (NOT DEFINED PROJECT_INTERFACE_INSTALL_DIR OR PROJECT_INTERFACE_INSTALL_DIR STREQUAL "")
    set(PROJECT_INTERFACE_INSTALL_DIR "include" CACHE PATH "" FORCE)
endif()


if (NOT DEFINED PROJECT_NAMESPACE OR PROJECT_NAMESPACE STREQUAL "")
    set(PROJECT_NAMESPACE "" CACHE PATH "" FORCE)
else()
    set(PROJECT_NAMESPACE ${PROJECT_NAMESPACE}::)
endif()


if(${CMAKE_GENERATOR_PLATFORM} MATCHES "86" OR ${CMAKE_GENERATOR_PLATFORM} MATCHES "32")
    set(TARGET_ARCH "x86")
else(${CMAKE_GENERATOR_PLATFORM} MATCHES "64")
    set(TARGET_ARCH "x64")
endif()

# library and cmake modules install dirs
set(LIB_INSTALL_DIR lib/${PROJECT_NAME}_${TARGET_ARCH})
set(CMAKE_INSTALL_DIR ${LIB_INSTALL_DIR}/cmake)
set(INTERFACE_INCLUDE_DIR "include")

# binding interface and library
target_include_directories(${PROJECT_NAME}
    PUBLIC "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR};${CMAKE_CURRENT_BINARY_DIR}>"
    INTERFACE $<INSTALL_INTERFACE:${INTERFACE_INCLUDE_DIR}>
)


install(TARGETS ${PROJECT_NAME} EXPORT ${PROJECT_NAME}_TARGETS DESTINATION ${LIB_INSTALL_DIR})

# preserve interface dir structure
foreach(_HEADER ${${PROJECT_INTERFACE_FILES}})
    get_filename_component(_DIR ${_HEADER} PATH)
    string(REPLACE "${PROJECT_INTERFACE_DIR}/" "" NEW_DIR ${_DIR})
    install(FILES ${_HEADER} DESTINATION "${PROJECT_INTERFACE_INSTALL_DIR}/${NEW_DIR}")
endforeach(_HEADER)

# create cmake-config files
include(CMakePackageConfigHelpers)
set(CONFIG_FILE "\
set(${PROJECT_NAME}_VERSION ${PROJECT_VERSION})

@PACKAGE_INIT@

get_filename_component(PACKAGE_LIB_DIR \"\${CMAKE_CURRENT_LIST_DIR}/../\" ABSOLUTE)
set_and_check(${PROJECT_NAME}_INCLUDE_DIR \"\@PACKAGE_INTERFACE_INCLUDE_DIR@\")
include(\"\${CMAKE_CURRENT_LIST_DIR}/${PROJECT_NAME}-targets.cmake\")

message(STATUS \"${PROJECT_NAME} library version: \${${PROJECT_NAME}_VERSION}\")
message(STATUS \"${PROJECT_NAME} library location: \${PACKAGE_LIB_DIR}\")

check_required_components(${PROJECT_NAME})")

file(WRITE ${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_NAME}-config.cmake.in ${CONFIG_FILE})

configure_package_config_file(${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_NAME}-config.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}/${PROJECT_NAME}-config.cmake
  INSTALL_DESTINATION ${CMAKE_INSTALL_DIR}
  PATH_VARS INTERFACE_INCLUDE_DIR)

write_basic_package_version_file(
  "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}/${PROJECT_NAME}-configversion.cmake"
  VERSION ${${PROJECT_NAME}_VERSION}
  COMPATIBILITY AnyNewerVersion
)

export(EXPORT ${PROJECT_NAME}_TARGETS
  FILE "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}/${PROJECT_NAME}-targets.cmake"
)


install(
  FILES
    "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}/${PROJECT_NAME}-config.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}/${PROJECT_NAME}-configversion.cmake"
  DESTINATION
    ${CMAKE_INSTALL_DIR}
)

install(
  EXPORT ${PROJECT_NAME}_TARGETS
  FILE ${PROJECT_NAME}-targets.cmake
  NAMESPACE
  ${PROJECT_NAMESPACE}
  DESTINATION ${CMAKE_INSTALL_DIR}
  )

  
endfunction(install_library)
