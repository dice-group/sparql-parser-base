include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

function(install_cpp_library TARGET_NAME FULL_INCLUDE_PATH)
    if(NOT ${ARGC} EQUAL 2)
        message(
                FATAL_ERROR
                "you did not specify the target and the include path in the parameter!")
    endif()

    target_include_directories(
            ${TARGET_NAME} PUBLIC $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)

    install(TARGETS ${TARGET_NAME}
            EXPORT ${TARGET_NAME}-targets
            ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
            LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
            RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
            INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
            )

    write_basic_package_version_file("${TARGET_NAME}-config-version.cmake"
            VERSION ${PROJECT_VERSION}
            COMPATIBILITY ExactVersion)

    configure_package_config_file(
            "${PROJECT_SOURCE_DIR}/cmake/lib-config.cmake.in"
            "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}-config.cmake"
            INSTALL_DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/${PROJECT_NAME}/cmake)
    # here we have two possibilities: either CMAKE_INSTALL_DATAROOTDIR (share) or CMAKE_INSTALL_LIBDIR (lib/lib64)
    # we just have to be consistent for one target

    install(
            EXPORT ${PROJECT_NAME}-targets
            FILE ${PROJECT_NAME}-targets.cmake
            NAMESPACE ${PROJECT_NAME}::
            DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/${PROJECT_NAME}/cmake)

    install(FILES "${PROJECT_BINARY_DIR}/${PROJECT_NAME}-config.cmake"
            "${PROJECT_BINARY_DIR}/${PROJECT_NAME}-config-version.cmake"
            DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/${PROJECT_NAME}/cmake)

    install(DIRECTORY ${FULL_INCLUDE_PATH}
            DESTINATION include
            FILES_MATCHING PATTERN "*.hpp" PATTERN "*.h")
endfunction()
