# Set the name for the generated test binary.
set(BINARY ${CMAKE_PROJECT_NAME}-Test)

# Add preprocessor definitions for code coverage.
add_definitions(-fprofile-arcs -ftest-coverage)

# Set the compiler options needed for Google Test.
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pthread -O0 -Wall --coverage")
set(CMAKE_CXX_OUTPUT_EXTENSION_REPLACE ON)

# Note the path to the Google Test directory.
set(GTEST     "googletest")
set(GTEST_LIB "gtest")
set(GTEST_DIR "${CMAKE_BINARY_DIR}/${PROJ_DEP_PATH}/${GTEST}")

# Download & compile the Google Test dependency on build.
include(ExternalProject)
ExternalProject_Add(${GTEST}
    GIT_REPOSITORY  https://github.com/google/${GTEST}
    GIT_TAG         main
    GIT_SHALLOW     true
    SOURCE_DIR      "${GTEST_DIR}"
    BINARY_DIR      "${GTEST_DIR}"
    TEST_COMMAND    ""
    INSTALL_COMMAND ""
    CMAKE_ARGS      -DBUILD_GMOCK=OFF -DINSTALL_GTEST=OFF
)

# Include and link against Google Test.
include_directories(${GTEST_DIR}/${GTEST}/include)
link_directories(${GTEST_DIR}/lib)

# Make sure to include incidental build files.
include_directories(${CMAKE_BINARY_DIR})

# Select the source files for the library.
file(GLOB_RECURSE LIB_SOURCES LIST_DIRECTORIES false
     ${CMAKE_SOURCE_DIR}/${PROJ_SRC_PATH}/*.cpp)

# Select the source files for the test executable.
file(GLOB_RECURSE TEST_SOURCES LIST_DIRECTORIES false
     ${CMAKE_CURRENT_SOURCE_DIR}/${PROJ_SRC_PATH}/*.cpp)

# Specify the source files to compile.
set(SOURCES ${LIB_SOURCES} ${TEST_SOURCES})

# Create our test executable.
add_executable(${BINARY} ${SOURCES})
add_test(NAME ${BINARY} COMMAND ${BINARY})

# Allow CMake to scan for tests using the library.
include(GoogleTest)
enable_testing()
gtest_discover_tests(${BINARY})

# Link the test executable against the
# testing framework & the project library.
target_link_libraries(${BINARY} PUBLIC
    ${GTEST_LIB} -fprofile-arcs)

# Install the generated test executable to the 'bin'
# subdirectory of the install path.
install(TARGETS ${BINARY} DESTINATION
    ${CMAKE_CURRENT_SOURCE_DIR}/${PROJ_BIN_PATH})
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/CTestTestfile.cmake
    DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/${PROJ_BIN_PATH})

# Setup directories for coverage.
set(OBJ_DIR ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/${BINARY}.dir)
set(COV_DIR ${CMAKE_BINARY_DIR}/${PROJ_COV_PATH})

# Create a custom target to generate a code-coverage report from
# compile-/run-time information coverage inforation.
add_custom_target(coverage
    COMMAND ${CMAKE_COMMAND} -E make_directory ${COV_DIR})
add_custom_command(TARGET coverage
    COMMAND gcov -b ${CMAKE_SOURCE_DIR}/${PROJ_SRC_PATH}/*.cpp
                 -s ${CMAKE_SOURCE_DIR}/${PROJ_SRC_PATH} -k -q
                 -o ${OBJ_DIR}/${PROJ_SRC_PATH} -m -f -j
    COMMAND ${CMAKE_CURRENT_BINARY_DIR}/${BINARY}
                  --gtest_brief=1 --gtest_print_time=0
    COMMAND lcov -c -b ${CMAKE_SOURCE_DIR}/${PROJ_SRC_PATH}
                 -d ${OBJ_DIR} -t "${CMAKE_PROJECT_NAME} Test Coverage"
                 --path ${CMAKE_SOURCE_DIR}/${PROJ_SRC_PATH}
                 --no-external -o ./coverage.info
    COMMAND genhtml ./coverage.info --output-directory .
    COMMAND lcov --list ./coverage.info
    WORKING_DIRECTORY ${COV_DIR}
)
add_dependencies(coverage ${BINARY})

# Install coverage files to the 'coverage/' output directory.
install(DIRECTORY ${COV_DIR}/
    DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/${PROJ_COV_PATH}
    OPTIONAL)
