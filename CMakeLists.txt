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

# add antrl4cpp artifacts to project environment
include_directories(${ANTLR4_INCLUDE_DIRS})

# add macros to generate ANTLR Cpp code from grammar
find_package(ANTLR REQUIRED)
antlr_target(Sparql Sparql.g4 LEXER PARSER LISTENER VISITOR PACKAGE Dice::tentris::sparql::parser)

# include generated files in project environment
include_directories(${ANTLR_Sparql_OUTPUT_DIR})


add_library(sparql-parser STATIC
        ${ANTLR_Sparql_CXX_OUTPUTS})

add_dependencies(sparql-parser antlr4_static)

set_target_properties(sparql-parser PROPERTIES
        CXX_STANDARD 17)

target_link_libraries(sparql-parser antlr4_static)


add_dependencies(sparql-parser
        antlr4_runtime)

target_include_directories(sparql-parser PRIVATE
        ${ANTLR4_INCLUDE_DIRS}
        ${PROJECT_SOURCE_DIR}/generated
        )

# Make package findable
configure_file(cmake/dummy-config.cmake.in sparql-parser-config.cmake @ONLY)

# Enable version checks in find_package
include(CMakePackageConfigHelpers)
write_basic_package_version_file(sparql-parser-config-version.cmake COMPATIBILITY SameMajorVersion)


# install and export target
install(TARGETS  sparql-parser
        EXPORT sparql-parser-targets
        ARCHIVE DESTINATION lib)


install(DIRECTORY "${ANTLR_Sparql_OUTPUT_DIR}"
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
            DESTINATION "share/doc/sparql-parser")
elseif (EXISTS ../../LICENSE.txt)
    install(FILES ../../LICENSE.txt
            DESTINATION "share/doc/sparql-parser")
endif ()
