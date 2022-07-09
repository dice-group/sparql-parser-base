cmake_minimum_required(VERSION 3.13)

project(sparql-parser-base VERSION 0.3.0)

include(cmake/boilerplate_init.cmake)
boilerplate_init()

option(CONAN_CMAKE "If this should use conan cmake to fetch dependencies" On)
if (IS_TOP_LEVEL AND CONAN_CMAKE)
    include(cmake/conan_cmake.cmake)
    install_packages_via_conan("${CMAKE_CURRENT_SOURCE_DIR}/conanfile.py" "")
endif ()

find_package(antlr4-runtime REQUIRED)

set(SPARQL_VERSION "1.1" CACHE STRING "SPARQL version" FORCE)
mark_as_advanced(SPARQL_VERSION)


set(ANTLR4_TAG "4.10.1" CACHE STRING "Antlr4 version" FORCE)
mark_as_advanced(ANTLR4_TAG)
set(ANTLR4_JAR_LOCATION "${PROJECT_BINARY_DIR}/antlr-${ANTLR4_TAG}-complete.jar")
if (NOT EXISTS "${ANTLR4_JAR_LOCATION}")
    file(DOWNLOAD https://www.antlr.org/download/antlr-${ANTLR4_TAG}-complete.jar ${ANTLR4_JAR_LOCATION} SHOW_PROGRESS)
endif ()

set(ANTLR_VERSION "${ANTLR4_TAG}")
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/antlr4cmake/antlr4-generator.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/antlr4cmake/antlr4-generator.cmake @ONLY)
include(${CMAKE_CURRENT_BINARY_DIR}/antlr4cmake/antlr4-generator.cmake)

message("antlr4-runtime_DIR ${antlr4-runtime_DIR}")


if (${SPARQL_VERSION} STREQUAL "1.1")
    file(CREATE_LINK ${CMAKE_CURRENT_SOURCE_DIR}/SparqlLexer_${SPARQL_VERSION}.g4
            ${CMAKE_CURRENT_BINARY_DIR}/SparqlLexer.g4)
    file(CREATE_LINK ${CMAKE_CURRENT_SOURCE_DIR}/SparqlParser_${SPARQL_VERSION}.g4
            ${CMAKE_CURRENT_BINARY_DIR}/SparqlParser.g4)
else ()
    file(CREATE_LINK ${CMAKE_CURRENT_SOURCE_DIR}/SparqlParser_${SPARQL_VERSION}.g4
            ${CMAKE_CURRENT_BINARY_DIR}/Sparql.g4
            )
endif ()


if (${SPARQL_VERSION} STREQUAL "1.1")
    message("Generating SPARQL 1.1 Parser. If you want to generate the legacy SPARQL 1.0 parser, use -SPARQL_VERSION=1.0 or the conan package option sparql-parser-base:sparql_version=1.0 .")
    antlr4_generate(
            SparqlLexer
            "${CMAKE_CURRENT_BINARY_DIR}/SparqlLexer.g4"
            LEXER
            FALSE # don't generate listener for lexer (not possible)
            FALSE # don't generate visitor  for lexer (not possible)
            "dice::sparql_parser::base"
    )
    file(CREATE_LINK ${ANTLR4_GENERATED_SRC_DIR}/SparqlLexer/SparqlLexer.tokens
            ${CMAKE_CURRENT_BINARY_DIR}/SparqlLexer.tokens)
    file(CREATE_LINK ${ANTLR4_GENERATED_SRC_DIR}/SparqlLexer/SparqlLexer.interp
            ${CMAKE_CURRENT_BINARY_DIR}/SparqlLexer.interp)
    antlr4_generate(
            SparqlParser
            "${CMAKE_CURRENT_BINARY_DIR}/SparqlParser.g4"
            PARSER
            TRUE # generate listener
            TRUE # generate visitor
            "dice::sparql_parser::base"
    )
else () # SPARQL 1.1
    message("Generating SPARQL 1.0 Parser. This is a legacy version and will not receive any more updates.")
    antlr4_generate(
            Sparql
            "${CMAKE_CURRENT_BINARY_DIR}/Sparql.g4"
            BOTH
            TRUE # generate listener
            TRUE # generate visitor
            "dice::sparql_parser::base"
    )
endif ()

if (${SPARQL_VERSION} STREQUAL "1.1")
    add_library("${PROJECT_NAME}"
            ${ANTLR4_SRC_FILES_SparqlLexer}
            ${ANTLR4_SRC_FILES_SparqlParser})
    target_include_directories(sparql-parser-base PUBLIC
            "$<BUILD_INTERFACE:${ANTLR4_INCLUDE_DIR_SparqlLexer}>"
            "$<BUILD_INTERFACE:${ANTLR4_INCLUDE_DIR_SparqlParser}>")

else ()
    add_library("${PROJECT_NAME}"
            ${ANTLR4_SRC_FILES_Sparql})
    target_include_directories(sparql-parser-base PUBLIC
            "$<BUILD_INTERFACE:${ANTLR4_INCLUDE_DIR_Sparql}>")
endif ()

add_library("${PROJECT_NAME}::${PROJECT_NAME}" ALIAS "${PROJECT_NAME}")

target_link_libraries(sparql-parser-base PUBLIC
        $<IF:$<BOOL:${BUILD_SHARED_LIBS}>,antlr4_shared,antlr4_static>
        )


set_target_properties(${PROJECT_NAME} PROPERTIES
        VERSION ${PROJECT_VERSION}
        SOVERSION ${PROJECT_VERSION_MAJOR}
        CXX_STANDARD 17
        CXX_EXTENSIONS OFF
        CXX_STANDARD_REQUIRED ON)

if (IS_TOP_LEVEL)
    include(cmake/install_library.cmake)
    install_cpp_library(${PROJECT_NAME} ${CMAKE_CURRENT_BINARY_DIR}/src/)
endif ()