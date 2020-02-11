cmake_minimum_required(VERSION 3.13)
#TODO: please move all code in here up into the main CMakeList.txt . This cmake in a subfolder should not be necessary.

set(sparql-GENERATED_DIR "${PROJECT_SOURCE_DIR}/sparql-grammer/generated")
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
        WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}/sparql-grammer"
        DEPENDS ${PROJECT_SOURCE_DIR}/sparql-grammer/Sparql.g4
        )

add_library(sparql-parser
        ${sparql-GENERATED_SRC}
        )

add_dependencies(sparql-parser
        GenerateParser
        antlr4_runtime)

target_include_directories(sparql-parser PRIVATE
        ${ANTLR4_INCLUDE_DIRS}
        ${sparql-GENERATED_DIR}
        )


target_link_libraries(sparql-parser antlr4_static)
set_target_properties(sparql-parser PROPERTIES
        CXX_STANDARD 17)


target_include_directories(sparql-parser PRIVATE
        ${CMAKE_CURRENT_BINARY_DIR}/antlr4_runtime/src/antlr4_runtime/runtime/Cpp/runtime/src/
        ${CMAKE_CURRENT_BINARY_DIR}/antlr4_runtime/src/antlr4_runtime/runtime/Cpp/runtime/src/src/misc
        ${CMAKE_CURRENT_BINARY_DIR}/antlr4_runtime/src/antlr4_runtime/runtime/Cpp/runtime/src/src/atn
        ${CMAKE_CURRENT_BINARY_DIR}/antlr4_runtime/src/antlr4_runtime/runtime/Cpp/runtime/src/src/dfa
        ${CMAKE_CURRENT_BINARY_DIR}/antlr4_runtime/src/antlr4_runtime/runtime/Cpp/runtime/src/src/tree
        ${CMAKE_CURRENT_BINARY_DIR}/antlr4_runtime/src/antlr4_runtime/runtime/Cpp/runtime/src/support
        ${PROJECT_SOURCE_DIR}/sparql_Grammer/generated
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


install(DIRECTORY "${sparql-GENERATED_DIR}"
        DESTINATION "include/sparql-parser"
        #        COMPONENT dev
        FILES_MATCHING PATTERN "*.h"
        )

install(DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/antlr4_runtime/src/antlr4_runtime/runtime/Cpp/runtime/src/"
        DESTINATION "include/sparql-parser"
        #        COMPONENT dev
        FILES_MATCHING PATTERN "*.h"
        )

# to install antlr4 runtime target
# TODO: may not be necessary
# TODO: please test if the conan package without does also work properly
set(ANTLR4_INSTALL ON)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/sparql-parser-config-version.cmake DESTINATION "share/sparql-parser/cmake")
#install(DIRECTORY include/sparql-parser DESTINATION "include")



