# cmake-modules
CMake files for find Qt, installing library with auto generated its CMake modules for find_package


## find_qt usage

*example CMakeLists.txt*
```cmake
project(...

...

include(find_qt.cmake)

find_qt(5.15.0) # default search path is C:/Qt
# find_qt(6.3.2 D:/Qt) # changed search path to D:/Qt
# find_qt(5) # selects latest Qt5 dir (example 5.15.0 and 5.15.2 this selects 5.15.2)
# find_qt(D:/Qt) # selects latest version of Qt in D:/Qt
# find_qt() # selects latest version of Qt

find_package(QT NAMES ...

...

```

## install_library usage

*example CMakeLists.txt*
```cmake
project(mylib VERSION 1.0 LANGUAGES CXX)

set(INTERFACE interface/mylib_exports.hpp interface/mylib.hpp)
set(HEADERS detail/mylib_private.hpp)
set(SOURCES detail/mylib.cpp detail/mylib_private.cpp)
set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/install/${CMAKE_PROJECT_NAME}_${PROJECT_VERSION})
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake) # this is for find this module (example this module in ${CMAKE_CURRENT_SOURCE_DIR}/cmake folder)
include(install_library)

add_library(${PROJECT_NAME} SHARED ${INTERFACE} ${HEADERS} ${SOURCES})
target_link_libraries(${PROJECT_NAME} PRIVATE example_dependency)
target_compile_definitions(${PROJECT_NAME} PRIVATE mylib_LIBRARY)

install_library(NAME ${PROJECT_NAME}            # install target for library
                INTERFACE_DIR interface         # interface headers directory
                INTERFACE_FILES INTERFACE       # interface headers variable
                INTERFACE_INSTALL_DIR mylib     # interface target directory in final include folder (example: include/mylib)
                NAMESPACE lib)                  # namespace for library (example: target_link_libraries(... lib::mylib ...))

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
```

## install_library usage

```cmake
project(mylib VERSION 1.0 LANGUAGES CXX)

set(INTERFACE interface/mylib_exports.hpp interface/mylib.hpp)
set(HEADERS detail/mylib_private.hpp)
set(SOURCES detail/mylib.cpp detail/mylib_private.cpp)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake) # this is for find this module (example this module in ${CMAKE_CURRENT_SOURCE_DIR}/cmake folder)
include(generate_rc)

generate_rc(RC_FILE
            NAME MyLib
            VERSION ${PROJECT_VERSION}
            COMPANY_NAME MyCompany
            FILE_DESCRIPTION mylib library
            )

add_library(${PROJECT_NAME} SHARED ${INTERFACE} ${HEADERS} ${SOURCES} ${RC_FILE})
target_link_libraries(${PROJECT_NAME} PRIVATE example_dependency)
target_compile_definitions(${PROJECT_NAME} PRIVATE mylib_LIBRARY)

```
