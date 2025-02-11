cmake_minimum_required(VERSION 3.21)

project(sparql-parser-base VERSION 0.3.9)

include(cmake/boilerplate_init.cmake)
boilerplate_init()

find_package(antlr4-runtime REQUIRED)

set(ANTLR4_TAG "4.13.1" CACHE STRING "Antlr4 version" FORCE)
mark_as_advanced(ANTLR4_TAG)
set(ANTLR4_JAR_LOCATION "${PROJECT_BINARY_DIR}/antlr-${ANTLR4_TAG}-complete.jar")
if (NOT EXISTS "${ANTLR4_JAR_LOCATION}")
    file(DOWNLOAD https://www.antlr.org/download/antlr-${ANTLR4_TAG}-complete.jar ${ANTLR4_JAR_LOCATION} SHOW_PROGRESS)
endif ()

set(ANTLR_VERSION "${ANTLR4_TAG}")
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/antlr4cmake/antlr4-generator.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/antlr4cmake/antlr4-generator.cmake @ONLY)
include(${CMAKE_CURRENT_BINARY_DIR}/antlr4cmake/antlr4-generator.cmake)

message("antlr4-runtime_DIR ${antlr4-runtime_DIR}")

message("Generating SPARQL 1.1 Parser")
antlr4_generate(
        SparqlLexer
        "${CMAKE_CURRENT_SOURCE_DIR}/SparqlLexer.g4"
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
        "${CMAKE_CURRENT_SOURCE_DIR}/SparqlParser.g4"
        PARSER
        TRUE # generate listener
        TRUE # generate visitor
        "dice::sparql_parser::base"
)

add_library("${PROJECT_NAME}"
        ${ANTLR4_SRC_FILES_SparqlLexer}
        ${ANTLR4_SRC_FILES_SparqlParser})
target_include_directories(sparql-parser-base PUBLIC
        "$<BUILD_INTERFACE:${ANTLR4_INCLUDE_DIR_SparqlLexer}>"
        "$<BUILD_INTERFACE:${ANTLR4_INCLUDE_DIR_SparqlParser}>")

add_library("${PROJECT_NAME}::${PROJECT_NAME}" ALIAS "${PROJECT_NAME}")

target_link_libraries(sparql-parser-base PUBLIC
        $<IF:$<BOOL:${BUILD_SHARED_LIBS}>,antlr4_shared,antlr4_static>
)


set_target_properties(${PROJECT_NAME} PROPERTIES
        VERSION ${PROJECT_VERSION}
        SOVERSION ${PROJECT_VERSION_MAJOR}
        CXX_STANDARD 17
        CXX_EXTENSIONS OFF
        CXX_STANDARD_REQUIRED ON
)

if (PROJECT_IS_TOP_LEVEL)
    include(cmake/install_library.cmake)
    install_cpp_library(${PROJECT_NAME} ${CMAKE_CURRENT_BINARY_DIR}/src/)
endif ()