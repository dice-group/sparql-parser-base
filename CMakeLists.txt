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

# set(ANTLR4_WITH_STATIC_CRT OFF)
add_definitions(-DANTLR4CPP_STATIC)

if (CMAKE_SYSTEM_NAME MATCHES "Linux")
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(UUID REQUIRED uuid)
endif ()




# Java is not necessary if building without demos.
find_package(Java COMPONENTS Runtime REQUIRED)


set(ANTLR4_TAG "4.8")
set(ANTLR_EXECUTABLE "${PROJECT_BINARY_DIR}/antlr-${ANTLR4_TAG}-complete.jar")
if (NOT EXISTS "${ANTLR_EXECUTABLE}")
    file(DOWNLOAD https://www.antlr.org/download/antlr-${ANTLR4_TAG}-complete.jar ${ANTLR_EXECUTABLE} SHOW_PROGRESS)
endif ()

include(ExternalAntlr4Cpp)

add_subdirectory(sparql-grammer)


if (EXISTS LICENSE.txt)
    install(FILES LICENSE.txt
            DESTINATION "share/doc/libantlr4")
elseif (EXISTS ../../LICENSE.txt)
    install(FILES ../../LICENSE.txt
            DESTINATION "share/doc/libantlr4")
endif ()
