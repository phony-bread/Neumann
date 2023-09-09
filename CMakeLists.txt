# Set the minimum CMake version due to required functionality.
cmake_minimum_required(VERSION 3.14)

# Make sure git is installed locally.
find_package(Git)

# Determine the version for the project file.
include(version.cmake)

# Define the project.
# Default the version, it will be set based on the git repository.
project(Neumann VERSION ${NEUMANN_SEMVER})

# Set some compiler options.
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# Potentially set the install prefix (but don't override).
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set(CMAKE_INSTALL_PREFIX "${PROJECT_SOURCE_DIR}")
endif()

# Set some standard directory paths.
set(PROJ_SRC_PATH src)
set(PROJ_EXL_PATH example)
set(PROJ_TST_PATH test)
set(PROJ_LIB_PATH lib)
set(PROJ_INC_PATH include)
set(PROJ_DOC_PATH docs)
set(PROJ_BIN_PATH bin)
set(PROJ_COV_PATH coverage)

# Setup the installed directories to be deleted on 'clean'.
set_property(DIRECTORY APPEND PROPERTY ADDITIONAL_MAKE_CLEAN_FILES
             "${PROJECT_SOURCE_DIR}/${PROJ_LIB_PATH}"
             "${PROJECT_SOURCE_DIR}/${PROJ_INC_PATH}"
             "${PROJECT_SOURCE_DIR}/${PROJ_DOC_PATH}"
             "${CMAKE_SOURCE_DIR}/${PROJ_TST_PATH}/{PROJ_COV_PATH}"
             "${CMAKE_SOURCE_DIR}/${PROJ_TST_PATH}/{PROJ_BIN_PATH}"
             "${CMAKE_SOURCE_DIR}/${PROJ_EXL_PATH}/{PROJ_BIN_PATH}")

# Add a target to clean the installed outputs.
add_custom_target(purge)
add_custom_command(TARGET purge
    COMMAND rm -rf ${PROJ_DEP_PATH} ${PROJ_LIB_PATH}
                   ${PROJ_BIN_PATH} ${PROJ_INC_PATH}
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
)

# Add a target to parse the version from git tags.
add_custom_target(version
    ${CMAKE_COMMAND} -D GIT_EXECUTABLE=${GIT_EXECUTABLE}
        -D SRC=${CMAKE_SOURCE_DIR}/${PROJ_SRC_PATH}/neumann_version.h.in
        -D DST=${CMAKE_BINARY_DIR}/neumann_version.h
        -P ${CMAKE_SOURCE_DIR}/version.cmake
)

# Include header files from the 'src' directory.
include_directories(${PROJ_SRC_PATH})

# Configure CMake to build the 'src' directory.
add_subdirectory(${PROJ_SRC_PATH})

# Configure CMake to build the 'example' directory.
add_subdirectory(${PROJ_EXL_PATH})

# Configure CMake to build the 'test' directory.
add_subdirectory(${PROJ_TST_PATH})
