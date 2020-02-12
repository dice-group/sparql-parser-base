cmake_minimum_required(VERSION 3.13)

project(sparql-parser VERSION 0.9.0)

if (NOT EXISTS ${CMAKE_BINARY_DIR}/CMakeCache.txt)
    if (NOT CMAKE_BUILD_TYPE)
        set(CMAKE_BUILD_TYPE "Release" CACHE STRING "" FORCE)
    endif ()
endif ()

if (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3 -fomit-frame-pointer -momit-leaf-frame-pointer")
else ()
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3 -fomit-frame-pointer")
endif ()
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -Wall -Wextra -g -O0")


# build antlr4
LIST(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/antlr4cmake)

set(ANTLR4_WITH_STATIC_CRT OFF)
add_definitions(-DANTLR4CPP_STATIC)

if (CMAKE_SYSTEM_NAME MATCHES "Linux")
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(UUID REQUIRED uuid)
endif ()

find_package(Java COMPONENTS Runtime REQUIRED)

set(ANTLR4_TAG "4.8")
set(ANTLR_EXECUTABLE "${PROJECT_BINARY_DIR}/antlr-${ANTLR4_TAG}-complete.jar")
if (NOT EXISTS "${ANTLR_EXECUTABLE}")
    file(DOWNLOAD https://www.antlr.org/download/antlr-${ANTLR4_TAG}-complete.jar ${ANTLR_EXECUTABLE} SHOW_PROGRESS)
endif ()
SET(ANTLR4_INSTALL ON)
include(ExternalAntlr4Cpp)


set(sparql-GENERATED_DIR "${PROJECT_SOURCE_DIR}/generated")
set(sparql-GENERATED_SRC
        ${sparql-GENERATED_DIR}/SparqlLexer.cpp
        ${sparql-GENERATED_DIR}/SparqlParser.cpp
        ${sparql-GENERATED_DIR}/SparqlBaseListener.cpp
        ${sparql-GENERATED_DIR}/SparqlBaseVisitor.cpp
        ${sparql-GENERATED_DIR}/SparqlListener.cpp
        ${sparql-GENERATED_DIR}/SparqlVisitor.cpp
        )

foreach (src_file ${sparql-GENERATED_SRC})
    set_source_files_properties(
            ${src_file}
            PROPERTIES
            GENERATED TRUE
    )
endforeach (src_file ${sparql-GENERATED_SRC})

add_custom_target(GenerateParser DEPENDS ${sparql-GENERATED_SRC})
add_custom_command(OUTPUT ${sparql-GENERATED_SRC}
        COMMAND
        ${CMAKE_COMMAND} -E make_directory ${sparql-GENERATED_DIR}/
        COMMAND
        java -jar "${ANTLR_EXECUTABLE}" -Werror -Dlanguage=Cpp -listener -visitor -o ${sparql-GENERATED_DIR}/ -package Dice::tentris::sparql::parser Sparql.g4
        WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}/"
        DEPENDS Sparql.g4
        )

add_library(sparql-parser STATIC
        ${sparql-GENERATED_SRC}
        )

set_target_properties(sparql-parser PROPERTIES
        CXX_STANDARD 17)


target_link_libraries(sparql-parser antlr4_static)

add_dependencies(sparql-parser
        GenerateParser
        antlr4_runtime)
message("da: ${ANTLR4_INCLUDE_DIRS}")
target_include_directories(sparql-parser PRIVATE
        ${ANTLR4_INCLUDE_DIRS}
#        ${ANTLR4_INCLUDE_DIRS}/
#        ${ANTLR4_INCLUDE_DIRS}/misc/
#        ${ANTLR4_INCLUDE_DIRS}/atn/
#        ${ANTLR4_INCLUDE_DIRS}/dfa/
#        ${ANTLR4_INCLUDE_DIRS}/tree/
#        ${ANTLR4_INCLUDE_DIRS}/support/
        ${PROJECT_SOURCE_DIR}/generated
        )

# Make package findable
configure_file(cmake/dummy-config.cmake.in sparql-parser-config.cmake @ONLY)

# Enable version checks in find_package
include(CMakePackageConfigHelpers)
write_basic_package_version_file(sparql-parser-config-version.cmake COMPATIBILITY SameMajorVersion)

# install and export target
install(TARGETS sparql-parser
        DESTINATION lib
        EXPORT sparql-parser-targets)


install(DIRECTORY "${PROJECT_SOURCE_DIR}/generated/"
        DESTINATION "include/sparql-parser"
        FILES_MATCHING PATTERN "*.h"
        )

install(DIRECTORY
"${ANTLR4_INCLUDE_DIRS}/"
        DESTINATION "include/"
        FILES_MATCHING PATTERN "*.h"
        )

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/sparql-parser-config-version.cmake DESTINATION "share/sparql-parser/cmake")

if (EXISTS LICENSE.txt)
    install(FILES LICENSE.txt
            DESTINATION "share/doc/libantlr4")
elseif (EXISTS ../../LICENSE.txt)
    install(FILES ../../LICENSE.txt
            DESTINATION "share/doc/libantlr4")
endif ()
