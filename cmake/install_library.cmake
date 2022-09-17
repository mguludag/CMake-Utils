cmake_minimum_required(VERSION 3.0)

# usage example:
# project(mylib VERSION 1.0 LANGUAGES CXX)
# 
# set(INTERFACE interface/mylib_exports.hpp interface/mylib.hpp)
# set(HEADERS detail/mylib_private.hpp)
# set(SOURCES detail/mylib.cpp detail/mylib_private.cpp)
# 
# add_library(${PROJECT_NAME} SHARED ${INTERFACE} ${HEADERS} ${SOURCES})
# target_link_libraries(${PROJECT_NAME} PRIVATE example_dependency)
# target_compile_definitions(${PROJECT_NAME} PRIVATE mylib_LIBRARY)
# 
# set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/install/${CMAKE_PROJECT_NAME}_${PROJECT_VERSION})
# set(INTERFACE_DIR interface)
# set(INTERFACE_INSTALL_DIR include/${PROJECT_NAME})
# set(NAMESPACE mylib)
# include(install_library.cmake)

if (NOT DEFINED INTERFACE_DIR OR INTERFACE_DIR STREQUAL "")
    set(INCLUDE_DIR "" CACHE PATH "" FORCE)
endif()

if (NOT DEFINED INTERFACE_INSTALL_DIR OR INTERFACE_INSTALL_DIR STREQUAL "")
    set(INTERFACE_INSTALL_DIR "include" CACHE PATH "" FORCE)
endif()


if (NOT DEFINED NAMESPACE OR NAMESPACE STREQUAL "")
    set(NAMESPACE "" CACHE PATH "" FORCE)
else()
    set(NAMESPACE ${NAMESPACE}::)
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
    PUBLIC "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/${INTERFACE_DIR};${CMAKE_CURRENT_BINARY_DIR}>"
    INTERFACE $<INSTALL_INTERFACE:${INTERFACE_INCLUDE_DIR}>
)


install(TARGETS ${PROJECT_NAME} EXPORT ${PROJECT_NAME}_TARGETS DESTINATION ${LIB_INSTALL_DIR})

# preserve interface dir structure
foreach(_HEADER ${INTERFACE})
    get_filename_component(_DIR ${_HEADER} PATH)
    install(FILES ${_HEADER} DESTINATION "${INTERFACE_INSTALL_DIR}/${_DIR}")
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
  ${NAMESPACE}
  DESTINATION ${CMAKE_INSTALL_DIR}
  )
