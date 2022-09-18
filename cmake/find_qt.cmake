cmake_minimum_required(VERSION 3.0)

function(find_qt qt_version)
if (NOT DEFINED ARGV1)
    set(qt_root "C:/Qt")
else()
    set(qt_root "${ARGV1}")
endif()

if(DEFINED CMAKE_PREFIX_PATH)
    set(CMAKE_PREFIX_PATH_TEMP "${CMAKE_PREFIX_PATH}")
endif()

if(WIN32)
    set(qmake "bin/qmake.exe")
else()
    set(qmake "bin/qmake")
endif()

set(qt_cmake_dir "lib/cmake")

set(QT_FOUND OFF)

set(VER_REGEX "^([0-9]+)\\.([0-9]+)\\.([0-9]+)$")

macro(__find_set_qt_version __path)
file(GLOB _children RELATIVE ${__path} ${__path}/*)
foreach(_child ${_children})
    if(EXISTS "${__path}/${_child}/${qt_cmake_dir}")
        set(qt_version ${child})
        break()
    endif()
endforeach()
endmacro()


if(NOT qt_version MATCHES ${VER_REGEX})
    file(GLOB children RELATIVE ${qt_root} ${qt_root}/*)
    list(REVERSE children)
    foreach(child ${children})
        if(IS_DIRECTORY ${qt_root}/${child})
            if("${child}" MATCHES "^${qt_version}" AND "${child}" MATCHES ${VER_REGEX})
                __find_set_qt_version("${qt_root}/${child}")
            endif()
        endif()
    endforeach()
endif()


set(curdir ${qt_root}/${qt_version})


file(GLOB children RELATIVE ${curdir} ${curdir}/*)
set(dirlist "")
foreach(child ${children})
    if(IS_DIRECTORY ${curdir}/${child})
    list(APPEND dirlist ${child})
    endif()
endforeach()

foreach(subdir ${dirlist})
    if(${CMAKE_GENERATOR_PLATFORM} MATCHES "64")
        if((EXISTS "${curdir}/${subdir}/${qt_cmake_dir}") AND ${subdir} MATCHES "64")
            set(CMAKE_PREFIX_PATH "${curdir}/${subdir}" PARENT_SCOPE)
            set(QT_FOUND ON)
        endif()
    elseif(${CMAKE_GENERATOR_PLATFORM} MATCHES "86" OR ${CMAKE_GENERATOR_PLATFORM} MATCHES "32")
        if((EXISTS "${curdir}/${subdir}/${qt_cmake_dir}") AND NOT ${subdir} MATCHES "64")  
            set(CMAKE_PREFIX_PATH "${curdir}/${subdir}" PARENT_SCOPE)
            set(QT_FOUND ON)
        endif()
    endif()
endforeach()

if(NOT ${QT_FOUND})
    message(SEND_ERROR  "No Qt found at " ${qt_root}/${qt_version})
else()
    message("Qt found at " ${qt_root}/${qt_version})
endif()

if(DEFINED CMAKE_PREFIX_PATH_TEMP)
    set(CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH_TEMP}" PARENT_SCOPE)
endif()

endfunction()
