# Set the compiler options.
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Set the output executable name.
set(BINARY ${CMAKE_PROJECT_NAME})

# Generate our version configuration source file.
#configure_file(lib_version.cpp.in lib_version.cpp @ONLY)

# Select the source & header files for compilation.
file(GLOB_RECURSE INCLUDES LIST_DIRECTORIES true *.h *.hpp)
file(GLOB_RECURSE SOURCES LIST_DIRECTORIES true *.cpp)
set(SOURCES ${SOURCES} ${INCLUDES})

# Create our output library.
add_library(${BINARY} STATIC ${SOURCES})

# Enable compilation database for static analysis.
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Install the output archive to the 'lib' subdirectory of the
# install path.
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
