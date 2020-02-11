cmake_minimum_required (VERSION 3.13)


set(sparql-GENERATED_SRC
        ${PROJECT_SOURCE_DIR}/sparql_Grammer/generated/SparqlLexer.cpp
        ${PROJECT_SOURCE_DIR}/sparql_Grammer/generated/SparqlParser.cpp
        ${PROJECT_SOURCE_DIR}/sparql_Grammer/generated/SparqlBaseListener.cpp
        ${PROJECT_SOURCE_DIR}/sparql_Grammer/generated/SparqlBaseVisitor.cpp
        ${PROJECT_SOURCE_DIR}/sparql_Grammer/generated/SparqlListener.cpp
        ${PROJECT_SOURCE_DIR}/sparql_Grammer/generated/SparqlVisitor.cpp
 )



foreach(src_file ${sparql-GENERATED_SRC})
    set_source_files_properties(
            ${src_file}
            PROPERTIES
            GENERATED TRUE
    )
endforeach(src_file ${sparql-GENERATED_SRC})

add_custom_target(GenerateParser DEPENDS ${sparql-GENERATED_SRC})
add_custom_command(OUTPUT ${sparql-GENERATED_SRC}
        COMMAND
        ${CMAKE_COMMAND} -E make_directory ${PROJECT_SOURCE_DIR}/sparql_Grammer/generated/
        COMMAND
        java -jar "../ANTLR_bin/antlr-4.8-complete.jar" -Werror -Dlanguage=Cpp -listener -visitor -o generated/ -package antlrcpptest Sparql.g4
        WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}/sparql_Grammer"
        DEPENDS ${PROJECT_SOURCE_DIR}/sparql_Grammer/Sparql.g4
        )

add_library(SparqlBaseParser
        ${sparql-GENERATED_SRC}
        )
add_dependencies(SparqlBaseParser GenerateParser)

target_include_directories( SparqlBaseParser PRIVATE
        ${PROJECT_SOURCE_DIR}/ANTLR_runtime/src
        ${PROJECT_SOURCE_DIR}/ANTLR_runtime/src/misc
        ${PROJECT_SOURCE_DIR}/ANTLR_runtime/src/atn
        ${PROJECT_SOURCE_DIR}/ANTLR_runtime/src/dfa
        ${PROJECT_SOURCE_DIR}/ANTLR_runtime/src/tree
        ${PROJECT_SOURCE_DIR}/ANTLR_runtime/src/support
        ${PROJECT_SOURCE_DIR}/sparql_Grammer/generated
)


target_link_libraries(SparqlBaseParser antlr4_static)




# Make package findable
configure_file(cmake/dummy-config.cmake.in SparqlBaseParser-config.cmake @ONLY)

# Enable version checks in find_package
include(CMakePackageConfigHelpers)
write_basic_package_version_file(SparqlBaseParser-config-version.cmake COMPATIBILITY SameMajorVersion)

# install and export target
install(TARGETS SparqlBaseParser
        DESTINATION lib
        EXPORT SparqlBaseParser-targets)


install(DIRECTORY "${PROJECT_SOURCE_DIR}/sparql_Grammer/generated/"
        DESTINATION "include/SparqlBaseParser"
#        COMPONENT dev
        FILES_MATCHING PATTERN "*.h"
        )

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/SparqlBaseParser-config-version.cmake DESTINATION "share/SparqlBaseParser/cmake")
#install(DIRECTORY include/SparqlBaseParser DESTINATION "include")



