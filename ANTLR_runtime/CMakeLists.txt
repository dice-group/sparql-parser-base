
include_directories(
        ${PROJECT_SOURCE_DIR}/ANTLR_runtime/src
        ${PROJECT_SOURCE_DIR}/ANTLR_runtime/src/atn
        ${PROJECT_SOURCE_DIR}/ANTLR_runtime/src/dfa
        ${PROJECT_SOURCE_DIR}/ANTLR_runtime/src/misc
        ${PROJECT_SOURCE_DIR}/ANTLR_runtime/src/support
        ${PROJECT_SOURCE_DIR}/ANTLR_runtime/src/tree
        ${PROJECT_SOURCE_DIR}/ANTLR_runtime/src/tree/pattern
        ${PROJECT_SOURCE_DIR}/ANTLR_runtime/src/tree/xpath
)


file(GLOB libantlrcpp_SRC
  "${PROJECT_SOURCE_DIR}/ANTLR_runtime/src/*.cpp"
  "${PROJECT_SOURCE_DIR}/ANTLR_runtime/src/atn/*.cpp"
  "${PROJECT_SOURCE_DIR}/ANTLR_runtime/src/dfa/*.cpp"
  "${PROJECT_SOURCE_DIR}/ANTLR_runtime/src/misc/*.cpp"
  "${PROJECT_SOURCE_DIR}/ANTLR_runtime/src/support/*.cpp"
  "${PROJECT_SOURCE_DIR}/ANTLR_runtime/src/tree/*.cpp"
  "${PROJECT_SOURCE_DIR}/ANTLR_runtime/src/tree/pattern/*.cpp"
  "${PROJECT_SOURCE_DIR}/ANTLR_runtime/src/tree/xpath/*.cpp"
)


add_library(antlr4_static STATIC ${libantlrcpp_SRC})

set(LIB_OUTPUT_DIR "${CMAKE_HOME_DIRECTORY}/dist") # put generated libraries here.
message(STATUS "Output libraries to ${LIB_OUTPUT_DIR}")

# make sure 'make' works fine even if ${LIB_OUTPUT_DIR} is deleted.
add_custom_target(make_lib_output_dir ALL
    COMMAND ${CMAKE_COMMAND} -E make_directory ${LIB_OUTPUT_DIR}
    )


add_dependencies(antlr4_static make_lib_output_dir)

if(CMAKE_SYSTEM_NAME MATCHES "Linux")
  target_link_libraries(antlr4_static ${UUID_LIBRARIES})
endif()


set(disabled_compile_warnings "-Wno-overloaded-virtual")



if("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")
  set(disabled_compile_warnings "${disabled_compile_warnings} -Wno-dollar-in-identifier-extension -Wno-four-char-constants")
elseif("${CMAKE_CXX_COMPILER_ID}" MATCHES "GNU" OR "${CMAKE_CXX_COMPILER_ID}" MATCHES "Intel")
  set(disabled_compile_warnings "${disabled_compile_warnings} -Wno-multichar")
endif()

set(extra_share_compile_flags "")
set(extra_static_compile_flags "")
if(WIN32)
  set(extra_share_compile_flags "-DANTLR4CPP_EXPORTS")
  set(extra_static_compile_flags "-DANTLR4CPP_STATIC")
endif(WIN32)


set(static_lib_suffix "")


set_target_properties(antlr4_static
                      PROPERTIES VERSION   ${ANTLR_VERSION}
                                 SOVERSION ${ANTLR_VERSION}
                                 OUTPUT_NAME "antlr4-runtime${static_lib_suffix}"
                                 ARCHIVE_OUTPUT_DIRECTORY ${LIB_OUTPUT_DIR}
                                 COMPILE_FLAGS "${disabled_compile_warnings} ${extra_static_compile_flags}")


install(TARGETS antlr4_static
        DESTINATION lib
        EXPORT antlr4-targets)

install(DIRECTORY "${PROJECT_SOURCE_DIR}/ANTLR_runtime/src/"
        DESTINATION "include/SparqlBaseParser/"
        COMPONENT dev 
        FILES_MATCHING PATTERN "*.h"
        )



