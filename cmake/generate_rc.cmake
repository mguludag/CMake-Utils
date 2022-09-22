cmake_minimum_required(VERSION 3.0)
include (CMakeParseArguments)

# generate_rc() function
#
# This function uses VersionInfo.in template file and VersionResource.rc file
# to generate WIN32 resource with version information and general resource strings.
#
# Usage:
#   generate_rc(
#     SomeOutputResourceVariable
#     NAME MyGreatProject
#     ICON ${PATH_TO_APP_ICON}
#     VERSION ${PROJECT_VERSION}
#     FILE_DESCRIPTION "MyGreatApp application"
#   )
#
# You can use generated resource for your executable targets:
#   add_executable(target-name ${target-files} ${SomeOutputResourceVariable})
#
# You can specify resource strings in arguments:
#   NAME               - name of executable (no defaults, ex: Microsoft Word)
#   ICON               - path to application icon (${CMAKE_SOURCE_DIR}/product.ico)
#   VERSION            - 
#   COMPANY_NAME       - your company name (no defaults)
#   COMPANY_COPYRIGHT  - ${COMPANY_NAME} (C) Copyright ${CURRENT_YEAR} is default
#   COMMENTS           - ${NAME} v${VERSION_MAJOR}.${VERSION_MINOR} is default
#   ORIGINAL_FILENAME  - ${NAME} is default
#   INTERNAL_NAME      - ${NAME} is default
#   FILE_DESCRIPTION   - ${NAME} is default
#   TRADEMARKS         - 
function(generate_rc rc_out)
set (options)
set (oneValueArgs
    NAME
    ICON
    VERSION
    COMPANY_NAME
    COMPANY_COPYRIGHT
    COMMENTS
    ORIGINAL_FILENAME
    INTERNAL_NAME
    FILE_DESCRIPTION
    TRADEMARKS)
set (multiValueArgs)
cmake_parse_arguments(PRODUCT "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})


set(target_binary_dir ${PROJECT_SOURCE_DIR})

set(target ${PRODUCT_NAME})

set(target_version ${PRODUCT_VERSION})

if(${CMAKE_GENERATOR_PLATFORM} MATCHES "86" OR ${CMAKE_GENERATOR_PLATFORM} MATCHES "32")
    set(TARGET_ARCH "x86")
else(${CMAKE_GENERATOR_PLATFORM} MATCHES "64")
    set(TARGET_ARCH "x64")
endif()


# Generate RC File
set(rc_file_output "${target_binary_dir}/${target}_resource.rc")

set(company_name "")
if (DEFINED PRODUCT_COMPANY_NAME)
    set(company_name "${PRODUCT_COMPANY_NAME}")
endif()

set(file_description "${PRODUCT_NAME} (${TARGET_ARCH})")
if (DEFINED PRODUCT_FILE_DESCRIPTION)
    set(file_description "${PRODUCT_FILE_DESCRIPTION} (${TARGET_ARCH})")
endif()

string(TIMESTAMP CURRENT_YEAR "%Y")
set(legal_copyright "Copyright \\xA9 ${CURRENT_YEAR} ${PRODUCT_COMPANY_NAME}")
if (DEFINED PRODUCT_COMPANY_COPYRIGHT)
    set(legal_copyright "${PRODUCT_COMPANY_COPYRIGHT}")
endif()

set(product_name "")
if (DEFINED PRODUCT_PRODUCT_NAME)
    set(product_name "${PRODUCT_PRODUCT_NAME}")
else()
    set(product_name "${PRODUCT_NAME}")
endif()

set(comments "${PRODUCT_NAME} v${PRODUCT_VERSION}")
if (DEFINED PRODUCT_COMMENTS)
    set(comments "${PRODUCT_COMMENTS}")
endif()

set(legal_trademarks "")
if (DEFINED PRODUCT_TRADEMARKS)
    set(legal_trademarks "${PRODUCT_TRADEMARKS}")
endif()

set(product_version "")
if (target_version)
    if(target_version MATCHES "[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+")
        # nothing to do
    elseif(target_version MATCHES "[0-9]+\\.[0-9]+\\.[0-9]+")
        set(target_version "${target_version}.0")
    elseif(target_version MATCHES "[0-9]+\\.[0-9]+")
        set(target_version "${target_version}.0.0")
    elseif (target_version MATCHES "[0-9]+")
        set(target_version "${target_version}.0.0.0")
    else()
        message(FATAL_ERROR "Invalid version format: '${target_version}'")
    endif()
    set(product_version "${target_version}")
else()
    set(product_version "0.0.0.0")
endif()

set(file_version "${product_version}")
string(REPLACE "." "," version_comma ${product_version})

set(original_file_name "${target}")
if (PRODUCT_ORIGINAL_FILENAME)
    set(original_file_name "${PRODUCT_ORIGINAL_FILENAME}")
endif()

set(internal_name "${PRODUCT_NAME}")
if (INTERNAL_NAME)
    set(internal_name "${INTERNAL_NAME}")
endif()

set(icons "")
if (PRODUCT_ICON)
    set(index 1)
    foreach( icon IN LISTS PRODUCT_ICON)
        string(APPEND icons "IDI_ICON${index}    ICON    \"${icon}\"\n")
        math(EXPR index "${index} +1")
    endforeach()
endif()

set(target_file_type "VFT_DLL")
if(target_type STREQUAL "EXECUTABLE")
    set(target_file_type "VFT_APP")
endif()

set(contents 
"#include <windows.h>
${icons}
VS_VERSION_INFO VERSIONINFO
FILEVERSION ${version_comma}
PRODUCTVERSION ${version_comma}
FILEFLAGSMASK 0x3fL
#ifdef _DEBUG
    FILEFLAGS VS_FF_DEBUG
#else
    FILEFLAGS 0x0L
#endif
FILEOS VOS_NT_WINDOWS32
FILETYPE ${target_file_type}
FILESUBTYPE VFT2_UNKNOWN
BEGIN
    BLOCK \"StringFileInfo\"
    BEGIN
        BLOCK \"040904b0\"
        BEGIN
            VALUE \"CompanyName\", \"${company_name}\"
            VALUE \"FileDescription\", \"${file_description}\"
            VALUE \"FileVersion\", \"${file_version}\"
            VALUE \"LegalCopyright\", \"${legal_copyright}\"
            VALUE \"OriginalFilename\", \"${original_file_name}\"
            VALUE \"ProductName\", \"${product_name}\"
            VALUE \"ProductVersion\", \"${product_version}\"
            VALUE \"Comments\", \"${comments}\"
            VALUE \"LegalTrademarks\", \"${legal_trademarks}\"
            VALUE \"InternalName\", \"${internal_name}\"
        END
    END
    BLOCK \"VarFileInfo\"
    BEGIN
        VALUE \"Translation\", 0x0409, 1200
    END
END
/* End of Version info */\n"
)

file(WRITE "${rc_file_output}.tmp" "${contents}")

# list(LENGTH CMAKE_CONFIGURATION_TYPES CMAKE_CONFIGURATION_TYPES_SIZE)
# if(CMAKE_CONFIGURATION_TYPES_SIZE GREATER 1)
# set(cfgs ${CMAKE_CONFIGURATION_TYPES})
# set(outputs "")
# foreach(cfg ${cfgs})
#     string(REPLACE "$<CONFIG>" "${cfg}" expanded_rc_file_output "${rc_file_output}")
#     list(APPEND outputs "${expanded_rc_file_output}")
# endforeach()
# else()
set(cfgs "${CMAKE_BUILD_TYPE}")
set(outputs "${rc_file_output}")
# endif()

while(outputs)
  list(POP_FRONT cfgs cfg)
  list(POP_FRONT outputs output)
  set(input "${output}.tmp")
  add_custom_command(OUTPUT "${output}"
      DEPENDS "${input}"
      COMMAND ${CMAKE_COMMAND} -E copy_if_different "${input}" "${output}")

      set (${rc_out} ${output} PARENT_SCOPE)

  # We would like to do the following:
  #     target_sources(${target} PRIVATE "$<$<CONFIG:${cfg}>:${output}>")
  # However, https://gitlab.kitware.com/cmake/cmake/-/issues/20682 doesn't let us.
#   add_library(${target}_${cfg}_rc OBJECT "${output}")
#   target_link_libraries(${target} PRIVATE "$<$<CONFIG:${cfg}>:${target}_${cfg}_rc>")
endwhile()

endfunction(generate_rc)
