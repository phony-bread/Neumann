# Set the compiler options.
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Set the output executable name.
set(BINARY ${CMAKE_PROJECT_NAME}-Example)

# Select the source & header files for compilation.
file(GLOB_RECURSE INCLUDES LIST_DIRECTORIES true *.h *.hpp)
file(GLOB_RECURSE SOURCES LIST_DIRECTORIES true *.cpp)
set(SOURCES ${SOURCES} ${INCLUDES})

# Create our output executable.
add_executable(${BINARY} ${SOURCES})

# Install the output executable to the 'bin' subdirectory
# of the install path.
install(TARGETS ${BINARY}
	RUNTIME DESTINATION ${PROJ_BIN_PATH})
