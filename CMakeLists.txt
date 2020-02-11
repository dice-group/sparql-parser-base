# -*- mode:cmake -*-
cmake_minimum_required(VERSION 3.13)
# 2.8 needed because of ExternalProject



project(SparqlBaseParser VERSION 0.9.0)


if (CMAKE_SYSTEM_NAME MATCHES "Linux")
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(UUID REQUIRED uuid)
endif ()




# Java is not necessary if building without demos.
find_package(Java COMPONENTS Runtime REQUIRED)


add_subdirectory(ANTLR_runtime)

add_subdirectory(sparql_Grammer)


if (EXISTS LICENSE.txt)
    install(FILES LICENSE.txt
            DESTINATION "share/doc/libantlr4")
elseif (EXISTS ../../LICENSE.txt)
    install(FILES ../../LICENSE.txt
            DESTINATION "share/doc/libantlr4")
endif ()

#install(FILES README.md VERSION
#    DESTINATION "share/doc/libantlr4")
#
#set(CPACK_PACKAGE_CONTACT "antlr-discussion@googlegroups.com")
#set(CPACK_PACKAGE_VERSION ${ANTLR_VERSION})
#include(CPack)
