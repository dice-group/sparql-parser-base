cmake_minimum_required(VERSION 3.13)

project(sparql-parser-base VERSION 0.2.1)

if (NOT EXISTS ${CMAKE_BINARY_DIR}/CMakeCache.txt)
    if (NOT CMAKE_BUILD_TYPE)
        set(CMAKE_BUILD_TYPE "Release" CACHE STRING "" FORCE)
    endif ()
endif ()

if (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    option(SPARQL_BASE_PARSER_WITH_LIBCXX "Building with libc++ (in Linux). To enable with: -DSPARQL_BASE_PARSER_WITH_LIBCXX=On" Off)
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3 -fomit-frame-pointer -momit-leaf-frame-pointer")
else ()
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3 -fomit-frame-pointer")
endif ()

set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -Wall -Wextra -g -O0")

if (DEFINED ${SPARQL_BASE_PARSER_MARCH})
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -march=${SPARQL_BASE_PARSER_MARCH}")
endif ()

# build antlr4
LIST(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/antlr4cmake)

set(ANTLR4_WITH_STATIC_CRT OFF)
add_definitions(-DANTLR4CPP_STATIC)

if (CMAKE_SYSTEM_NAME MATCHES "Linux")
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(UUID REQUIRED uuid)
endif ()

find_package(Java COMPONENTS Runtime REQUIRED)

set(ANTLR4_TAG "4.9.1")
set(ANTLR_EXECUTABLE "${PROJECT_BINARY_DIR}/antlr-${ANTLR4_TAG}-complete.jar")
if (NOT EXISTS "${ANTLR_EXECUTABLE}")
    file(DOWNLOAD https://www.antlr.org/download/antlr-${ANTLR4_TAG}-complete.jar ${ANTLR_EXECUTABLE} SHOW_PROGRESS)
endif ()
SET(ANTLR4_INSTALL ON)
include(ExternalAntlr4Cpp)

# add antrl4cpp artifacts to project environment
include_directories(${ANTLR4_INCLUDE_DIRS})

if (NOT DEFINED SPARQL_BASE_PARSER_SPARQL_VERSION)
    set(SPARQL_BASE_PARSER_SPARQL_VERSION "1.1")
else ()
    if (NOT (${SPARQL_BASE_PARSER_SPARQL_VERSION} STREQUAL "1.0" OR ${SPARQL_BASE_PARSER_SPARQL_VERSION} STREQUAL "1.1"))
        message(FATAL_ERROR "SPARQL_BASE_PARSER_SPARQL_VERSION must be \"1.1\" or \"1.0\" but is ${SPARQL_BASE_PARSER_SPARQL_VERSION}")
    endif ()
endif ()

if (${SPARQL_BASE_PARSER_SPARQL_VERSION} STREQUAL "1.1")
    file(CREATE_LINK ${CMAKE_CURRENT_SOURCE_DIR}/SparqlLexer_${SPARQL_BASE_PARSER_SPARQL_VERSION}.g4
            ${CMAKE_CURRENT_SOURCE_DIR}/SparqlLexer.g4)
    file(CREATE_LINK ${CMAKE_CURRENT_SOURCE_DIR}/SparqlParser_${SPARQL_BASE_PARSER_SPARQL_VERSION}.g4
            ${CMAKE_CURRENT_SOURCE_DIR}/SparqlParser.g4)
else ()
    file(CREATE_LINK ${CMAKE_CURRENT_SOURCE_DIR}/SparqlParser_${SPARQL_BASE_PARSER_SPARQL_VERSION}.g4
            ${CMAKE_CURRENT_SOURCE_DIR}/Sparql.g4
            )
endif ()

# add macros to generate ANTLR Cpp code from grammar
find_package(ANTLR REQUIRED)
if (${SPARQL_BASE_PARSER_SPARQL_VERSION} STREQUAL "1.1")
    message("Generating SPARQL 1.1 Parser. If you want to generate the legacy SPARQL 1.0 parser, use -SPARQL_BASE_PARSER_SPARQL_VERSION=1.0 or the conan package option sparql-parser-base:sparql_version=1.0 .")
    antlr_target(SparqlLexer SparqlLexer.g4 LEXER
            PACKAGE Dice::sparql_parser::base)
    antlr_target(SparqlParser SparqlParser.g4 PARSER
            PACKAGE Dice::sparql_parser::base
            DEPENDS_ANTLR SparqlLexer
            LISTENER
            VISITOR
            COMPILE_FLAGS -lib ${ANTLR_SparqlLexer_OUTPUT_DIR})
else () # SPARQL 1.1
    message("Generating SPARQL 1.0 Parser. This is a legacy version and will most probably receive no more updates.")
    antlr_target(Sparql Sparql.g4 LEXER PARSER LISTENER VISITOR
            PACKAGE Dice::sparql_parser::base
            )
endif ()

# include generated files in project environment
if (${SPARQL_BASE_PARSER_SPARQL_VERSION} STREQUAL "1.1")
    add_library(sparql-parser-base
            ${ANTLR_SparqlLexer_CXX_OUTPUTS}
            ${ANTLR_SparqlParser_CXX_OUTPUTS})
    target_include_directories(sparql-parser-base PUBLIC
            ${ANTLR_SparqlLexer_OUTPUT_DIR}
            ${ANTLR_SparqlParser_OUTPUT_DIR})
else ()
    add_library(sparql-parser-base
            ${ANTLR_Sparql_CXX_OUTPUTS})
    target_include_directories(sparql-parser-base PUBLIC
            ${ANTLR_Sparql_OUTPUT_DIR})
endif ()

set_target_properties(sparql-parser-base PROPERTIES
        CXX_STANDARD 17)

target_link_libraries(sparql-parser-base PUBLIC antlr4_static)


add_dependencies(sparql-parser-base
        antlr4_static)

target_include_directories(sparql-parser-base PUBLIC
        ${ANTLR4_INCLUDE_DIRS}
        ${PROJECT_SOURCE_DIR}/generated
        )

# Make package findable
configure_file(cmake/dummy-config.cmake.in sparql-parser-base-config.cmake @ONLY)
configure_file(antlr4cmake/antlr4-runtime.cmake.in antlr4-runtime-config.cmake @ONLY)

# Enable version checks in find_package
include(CMakePackageConfigHelpers)
write_basic_package_version_file(sparql-parser-base-config-version.cmake COMPATIBILITY SameMajorVersion)
write_basic_package_version_file(antlr4-runtime-config-version.cmake COMPATIBILITY SameMajorVersion)

# install and export target
install(TARGETS sparql-parser-base
        EXPORT sparql-parser-base-targets
        ARCHIVE DESTINATION lib)


install(DIRECTORY "${ANTLR_SparqlParser_OUTPUT_DIR}"
        DESTINATION "include/"
        FILES_MATCHING PATTERN "*.h"
        )

if (${SPARQL_BASE_PARSER_SPARQL_VERSION} STREQUAL "1.1")
    install(DIRECTORY "${ANTLR_SparqlParser_OUTPUT_DIR}"
            DESTINATION "include/"
            FILES_MATCHING PATTERN "*.h"
            )
    install(DIRECTORY "${ANTLR_SparqlLexer_OUTPUT_DIR}"
            DESTINATION "include/"
            FILES_MATCHING PATTERN "*.h"
            )
else ()
    install(DIRECTORY "${ANTLR_Sparql_OUTPUT_DIR}"
            DESTINATION "include/"
            FILES_MATCHING PATTERN "*.h"
            )
endif ()

install(DIRECTORY
        "${ANTLR4_INCLUDE_DIRS}/"
        DESTINATION "include/"
        FILES_MATCHING PATTERN "*.h"
        )

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/antlr4-runtime-config-version.cmake DESTINATION "share/antlr4-runtime/cmake")

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/sparql-parser-base-config-version.cmake DESTINATION "share/sparql-parser-base/cmake")

if (EXISTS LICENSE.txt)
    install(FILES LICENSE.txt
            DESTINATION "share/doc/sparql-parser-base")
elseif (EXISTS ../../LICENSE.txt)
    install(FILES ../../LICENSE.txt
            DESTINATION "share/doc/sparql-parser-base")
endif ()

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/antlr4_runtime/src/antlr4_runtime/LICENSE.txt
        DESTINATION "share/licenses/antlr4-runtime")
