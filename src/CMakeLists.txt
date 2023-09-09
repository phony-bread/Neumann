# Set the compiler options.
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Set the output executable name.
set(BINARY ${CMAKE_PROJECT_NAME})

# Select the source & header files for compilation.
file(GLOB_RECURSE INCLUDES LIST_DIRECTORIES true *.h *.hpp)
file(GLOB_RECURSE SOURCES LIST_DIRECTORIES true *.cpp)
set(SOURCES ${SOURCES} ${INCLUDES})

# Create the output library.
add_library(${BINARY} STATIC ${SOURCES})

# Make sure the version detection runs before the library is built.
add_dependencies(${BINARY} version)

# Make sure the compiler has access to the configured version file.
include_directories(${CMAKE_BINARY_DIR})

# Enable compilation database for static analysis.
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Install the output archive to the 'lib' subdirectory
# of the install path.
install(TARGETS ${BINARY}
	ARCHIVE DESTINATION ${PROJ_LIB_PATH}
	PUBLIC_HEADER DESTINATION ${PROJ_INC_PATH})

# Install the exported include files to the 'include' subdirectory
# of the install path.
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
    DESTINATION ${PROJ_INC_PATH}
    FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp")

# Install the generated static library to the 'lib'
# subdirectory of the install path.
install(TARGETS ${BINARY} DESTINATION ${PROJ_LIB_PATH})
