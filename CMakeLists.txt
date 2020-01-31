cmake_minimum_required(VERSION 3.15)
project(sparql_parser VERSION 0.1.0)
set(CMAKE_CXX_STANDARD 17)

if (NOT EXISTS ${CMAKE_BINARY_DIR}/CMakeCache.txt)
    if (NOT CMAKE_BUILD_TYPE)
        set(CMAKE_BUILD_TYPE "Release" CACHE STRING "" FORCE)
    endif ()
endif ()

if (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3 -fomit-frame-pointer -momit-leaf-frame-pointer")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -stdlib=libc++ -lc++abi")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++ -v")

    set(CMAKE_THREAD_LIBS_INIT "-lpthread")
    set(CMAKE_HAVE_THREADS_LIBRARY 1)
    set(CMAKE_USE_WIN32_THREADS_INIT 0)
    set(CMAKE_USE_PTHREADS_INIT 1)
    set(THREADS_PREFER_PTHREAD_FLAG ON)
else ()
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3 -fomit-frame-pointer")
endif ()
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -Wall -Wextra -g -O0")


# build antlr4
LIST(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/antlr4cmake)
set(ANTLR4_TAG "4.8")
if (NOT EXISTS "${PROJECT_BINARY_DIR}/antlr-${ANTLR4_TAG}-complete.jar")
    file(DOWNLOAD https://www.antlr.org/download/antlr-${ANTLR4_TAG}-complete.jar ${PROJECT_BINARY_DIR}/antlr-${ANTLR4_TAG}-complete.jar SHOW_PROGRESS)
endif ()
set(ANTLR_EXECUTABLE ${PROJECT_BINARY_DIR}/antlr-${ANTLR4_TAG}-complete.jar)
set(ANTLR4_WITH_STATIC_CRT OFF)
add_definitions(-DANTLR4CPP_STATIC)
include(ExternalAntlr4Cpp)
include_directories(${ANTLR4_INCLUDE_DIRS})

find_package(ANTLR REQUIRED)

antlr_target(SPARQLGrammar
        Sparql.g4
        LEXER PARSER LISTENER VISITOR
        PACKAGE DICE::tentris::sparql)

# installation directories
set(antlr4_sparql_INSTALL_INCLUDE_DIR "include" CACHE STRING "The installation include directory")
set(antlr4_sparql_INSTALL_CMAKE_DIR "share/antlr4_sparql/cmake" CACHE STRING "The installation cmake directory")


set(ANTLR_SPARQLGrammar_headers ${ANTLR_SPARQLGrammar_CXX_OUTPUTS})
list(FILTER ANTLR_SPARQLGrammar_headers INCLUDE REGEX ".*\\.h")
file(COPY ${ANTLR_SPARQLGrammar_headers} DESTINATION ${CMAKE_SOURCE_DIR}/include)

set(ANTLR_SPARQLGrammar_source ${ANTLR_SPARQLGrammar_CXX_OUTPUTS})
list(FILTER ANTLR_SPARQLGrammar_source INCLUDE REGEX ".*\\.cpp")
file(COPY ${ANTLR_SPARQLGrammar_source} DESTINATION ${CMAKE_SOURCE_DIR}/source)

add_library(antlr4_sparql
        ${ANTLR_SPARQLGrammar_source}
        )

target_include_directories(antlr4_sparql
        PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
        PRIVATE
        ${ANTLR4_INCLUDE_DIRS}
        ${CMAKE_CURRENT_SOURCE_DIR}/src
        )


target_link_libraries(antlr4_sparql antlr4_static)
add_dependencies(antlr4_sparql antlr4_static)

configure_file(cmake/dummy-config.cmake.in antlr4_sparql-config.cmake @ONLY)

# Enable version checks in find_package
include(CMakePackageConfigHelpers)
write_basic_package_version_file(antlr4_sparql-config-version.cmake COMPATIBILITY SameMajorVersion)

# install and export target
install(TARGETS antlr4_sparql EXPORT antlr4_sparql-targets)

install(EXPORT antlr4_sparql-targets
        FILE antlr4_sparql-config.cmake
        NAMESPACE Dice::
        DESTINATION ${antlr4_sparql_INSTALL_CMAKE_DIR}
        )

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/antlr4_sparql-config-version.cmake DESTINATION ${antlr4_sparql_INSTALL_CMAKE_DIR})
install(DIRECTORY include/ DESTINATION ${antlr4_sparql_INSTALL_INCLUDE_DIR})

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/antlr4_sparql-config-version.cmake DESTINATION ${antlr4_sparql_INSTALL_CMAKE_DIR})
install(DIRECTORY thirdparty/cppitertools/ DESTINATION ${antlr4_sparql_INSTALL_INCLUDE_DIR})