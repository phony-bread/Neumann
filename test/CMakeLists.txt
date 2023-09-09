# Set the name for the generated test binary.
set(BINARY ${CMAKE_PROJECT_NAME}-Test)

# Add preprocessor definitions for code coverage.
add_definitions(-fprofile-arcs -ftest-coverage)

# Set the compiler options needed for Google Test.
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pthread -O0 --coverage")
set(CMAKE_CXX_OUTPUT_EXTENSION_REPLACE ON)

# Note the path to the Google Test directory.
set(GTEST     "googletest")
set(GTEST_DIR "${CMAKE_BINARY_DIR}/dep/${GTEST}")

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

# Setup options for Google Test.
#option(BUILD_GMOCK   "" OFF)
#option(INSTALL_GTEST "" OFF)

# Import Google Test.
#add_subdirectory("/usr/src/googletest" ${CMAKE_BINARY_DIR}/gtest)
#include_directories(${GTEST_INCLUDE_DIRS})

# Select the source & header files for compilation.
file(GLOB_RECURSE TEST_SOURCES LIST_DIRECTORIES false *.h *.cpp)
set(SOURCES ${TEST_SOURCES})

# Create our test executable.
add_executable(${BINARY} ${SOURCES})
#add_dependencies(${BINARY} gtest)
add_test(NAME ${BINARY} COMMAND ${BINARY})

# Allow CMake to scan for tests using the library.
include(GoogleTest)
enable_testing()
gtest_discover_tests(${BINARY})

# Link the test executable agains the
# testing framework & the project library.
target_link_libraries(${BINARY} PUBLIC gtest -fprofile-arcs)

# Install the generated test executable to the 'bin'
# subdirectory of the install path.
install(TARGETS ${BINARY} DESTINATION ${PROJ_BIN_PATH})
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/CTestTestfile.cmake DESTINATION ${PROJ_BIN_PATH})

# Setup directories for coverage.
set(OBJ_DIR ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/${BINARY}.dir)
set(COV_DIR ${CMAKE_BINARY_DIR}/${PROJ_COV_PATH})
file(MAKE_DIRECTORY ${COV_DIR})

# Create a custom target to gather compile-tim
# code-coverage information.
add_custom_target(gcov
    COMMAND mkdir -p ${COV_DIR}
)
add_custom_command(TARGET gcov
    COMMAND gcov -b ${CMAKE_SOURCE_DIR}/${PROJ_SRC_PATH}/*.cpp
                 -s ${CMAKE_SOURCE_DIR}/${PROJ_SRC_PATH} -k -q
                 -o ${OBJ_DIR}/__/${PROJ_SRC_PATH} -m -f -j
    WORKING_DIRECTORY ${COV_DIR}
)
add_dependencies(gcov ${BINARY})

# Create a custom target to run the text executable to
# generate a test report & run-time coverage information.
add_custom_target(test)
add_custom_command(TARGET test
    COMMAND ${CMAKE_CURRENT_BINARY_DIR}/${BINARY} --gtest_output="xml:report.xml"
    WORKING_DIRECTORY ${COV_DIR}
)
add_dependencies(test ${BINARY})

# Create a custom target to gather run-time code-coverage information.
add_custom_target(lcov)
add_custom_command(TARGET lcov
    COMMAND lcov -c -b ${CMAKE_SOURCE_DIR}/${PROJ_SRC_PATH}
                 -d ${OBJ_DIR} -t "${BINARY} Test Coverage"
                 --path ${CMAKE_SOURCE_DIR}/${PROJ_SRC_PATH}
                 --no-external -o ./coverage.info
    WORKING_DIRECTORY ${COV_DIR}
)
add_dependencies(lcov test gcov)

# Create a custom target to generate a code-coverage report from
# compile-/run-time information coverage inforation.
# Also print a code-coverage summary for the CI pipeline to parse.
add_custom_target(coverage)
add_custom_command(TARGET coverage
    COMMAND genhtml ./coverage.info --output-directory ./
                    --num-spaces 4 --demangle-cpp
    COMMAND lcov --list ./coverage.info
    WORKING_DIRECTORY ${COV_DIR}
)
add_dependencies(coverage lcov)

# Install coverage files to the 'coverage/' output directory.
install(DIRECTORY ${COV_DIR}/ DESTINATION ${PROJ_COV_PATH})
