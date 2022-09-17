# CMake-Utils
CMake files for find Qt, installing library with auto generated its CMake modules for find_package


## find_qt usage

*example CMakeLists.txt*
```cmake
project(...

...

include(find_qt.cmake)

find_qt(5.15.0) # default search path is C:/Qt
# find_qt(6.3.2 D:/Qt) # changed search path to D:/Qt

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

add_library(${PROJECT_NAME} SHARED ${INTERFACE} ${HEADERS} ${SOURCES})
target_link_libraries(${PROJECT_NAME} PRIVATE example_dependency)
target_compile_definitions(${PROJECT_NAME} PRIVATE mylib_LIBRARY)

set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/install/${CMAKE_PROJECT_NAME}_${PROJECT_VERSION})
set(INTERFACE_DIR interface)
set(INTERFACE_INSTALL_DIR include/${PROJECT_NAME})
set(NAMESPACE mylib)
include(install_library.cmake)
```
