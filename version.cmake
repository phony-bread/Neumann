# Use git to determine the version tag.
if(GIT_EXECUTABLE)
    execute_process(
        COMMAND ${GIT_EXECUTABLE} describe --tags --dirty --match "v*"
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        OUTPUT_VARIABLE GIT_DESCRIBE_VERSION
        RESULT_VARIABLE GIT_DESCRIBE_ERR_CODE
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    # Ensure the git command succeeded.
    if(NOT GIT_DESCRIBE_ERR_CODE)
        set(NEUMANN_VERSION ${GIT_DESCRIBE_VERSION})
    endif()
endif()

# Set the default fallback version.
if(NOT DEFINED NEUMANN_VERSION)
    set(NEUMANN_SEMVER 0.0.0)
    set(NEUMANN_VERSION v${NEUMANN_SEMVER}-dev)
    message(WARNING "Failed to get version tag from git, "
        "using default \"${NEUMANN_VERSION}\".")
endif()

# Generate our version configuration source file.
if(DEFINED SRC AND DEFINED DST)
    configure_file(${SRC} ${DST} @ONLY)
endif()
