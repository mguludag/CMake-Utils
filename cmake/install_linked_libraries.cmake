cmake_minimum_required(VERSION 3.0)

function(install_linked_libraries)
    if (DEFINED ARGV0)
      set(install_target ${ARGV0})
    else()
      set(install_target ${PROJECT_NAME})
    endif()

    if(${CMAKE_GENERATOR_PLATFORM} MATCHES "86" OR ${CMAKE_GENERATOR_PLATFORM} MATCHES "32")
      set(TARGET_ARCH "")
    else(${CMAKE_GENERATOR_PLATFORM} MATCHES "64")
      set(TARGET_ARCH "64")
    endif()

    get_target_property(target_type ${install_target} TYPE)

    if(target_type STREQUAL "EXECUTABLE")
      set(dest_dir "lib")
    else()
      set(dest_dir "bin${TARGET_ARCH}")
    endif()

    set(DLL_PATHS "")
    set(PLUGIN_PATHS "")
    get_target_property(OUT ${install_target} LINK_LIBRARIES)
    foreach(lib ${OUT})
      string(TOUPPER ${CMAKE_BUILD_TYPE} BUILD_T)
      get_target_property(dll ${lib} IMPORTED_LOCATION_${BUILD_T})
      get_filename_component(DLL_NAME ${dll} NAME)
      get_filename_component(DLL_PATH ${dll} PATH)
      list(APPEND DLL_PATHS ${DLL_PATH})
      if(DLL_NAME MATCHES "Qt")
        list(APPEND PLUGIN_PATHS ${DLL_PATH}/../plugins)
        list(APPEND PLUGIN_PATHS ${DLL_PATH}/../qml)
      endif()
    endforeach()
    
    list(REMOVE_DUPLICATES DLL_PATHS)
    list(REMOVE_DUPLICATES PLUGIN_PATHS)

    foreach(path ${PLUGIN_PATHS})
      install(DIRECTORY ${path} DESTINATION ${CMAKE_INSTALL_PREFIX}/${dest_dir})
    endforeach(path DLL_PATHS)

    foreach(path ${DLL_PATHS}) 
      if(WIN32)
        file(GLOB dll "${path}/*.dll")
      else()
        file(GLOB dll "${path}/*.so*")
      endif(WIN32)
      install(FILES ${dll} DESTINATION ${CMAKE_INSTALL_PREFIX}/${dest_dir})
    endforeach(path DLL_PATHS)

    get_target_property(target_type_ ${install_target} TYPE)

    if(WIN32)
      if(target_type_ STREQUAL "EXECUTABLE")
        set(RUN_FILE "\
        @echo off
        cd \"lib\" & start \"\" \"../bin/${install_target}.exe\"
        exit
        ")
        file(WRITE ${CMAKE_INSTALL_PREFIX}/run.bat ${RUN_FILE})
      endif()
    else()
      if(target_type_ STREQUAL "EXECUTABLE")
        set(RUN_FILE "\
        export LD_LIBRARY_PATH=./lib:$LD_LIBRARY_PATH;
        export PATH=./lib:$PATH;
        export QT_PLUGIN_PATH=./lib/plugins;
        ./\"${install_target}\"
        ")
        file(WRITE ${CMAKE_INSTALL_PREFIX}/run.sh ${RUN_FILE})
      endif()
    endif(WIN32)
  
endfunction(install_linked_libraries)
