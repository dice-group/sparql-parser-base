cmake_minimum_required(VERSION 3.13)

project(sparql-parser-base VERSION 0.1.1)

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

if(NOT DEFINED ${TENTRIS_MARCH})
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -march=x86-64")
else()
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -march=${TENTRIS_MARCH}")
endif()

option(SPARQL_BASE_PARSER_WITH_LIBCXX "Building with libc++ (in Linux). To enable with: -DWITH_LIBCXX=On" Off)

option(SPARQL_BASE_PARSER_MARCH "Allows you to set the -march parameter. If you are building for your local machine, you should set it to -DSPARQL_BASE_PARSER_MARCH=native" x86-64)

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

# add antrl4cpp artifacts to project environment
include_directories(${ANTLR4_INCLUDE_DIRS})

# add macros to generate ANTLR Cpp code from grammar
find_package(ANTLR REQUIRED)
antlr_target(SparqlLexer SparqlLexer.g4 LEXER
        PACKAGE Dice::tentris::SparqlParserBase)
antlr_target(SparqlParser SparqlParser.g4 PARSER
        PACKAGE Dice::tentris::SparqlParserBase
        DEPENDS_ANTLR SparqlLexer
        LISTENER
        VISITOR
        COMPILE_FLAGS -lib ${ANTLR_SparqlLexer_OUTPUT_DIR})

# include generated files in project environment
include_directories(${ANTLR_SparqlLexer_OUTPUT_DIR})
include_directories(${ANTLR_SparqlParser_OUTPUT_DIR})

add_library(sparql-parser-base
        ${ANTLR_SparqlLexer_CXX_OUTPUTS}
        ${ANTLR_SparqlParser_CXX_OUTPUTS})


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
install(TARGETS  sparql-parser-base
        EXPORT sparql-parser-base-targets
        ARCHIVE DESTINATION lib)


install(DIRECTORY "${ANTLR_SparqlParser_OUTPUT_DIR}"
        DESTINATION "include/"
        FILES_MATCHING PATTERN "*.h"
        )

install(DIRECTORY "${ANTLR_SparqlLexer_OUTPUT_DIR}"
        DESTINATION "include/"
        FILES_MATCHING PATTERN "*.h"
        )

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
