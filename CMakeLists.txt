cmake_minimum_required(VERSION 3.0.2)

project(cppskeleton)

include(ExternalProject)

# {{{ Targets
# {{{ asan: Clang AddressSanitizer

option(CLANG_ASAN "Enable Clang AddressSanitizer"   OFF)
if (CLANG_ASAN)
  message(STATUS "Using Clang AddressSanitizer")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitize=address -fno-omit-frame-pointer")
endif()

# }}}
# {{{ msan: Clang MemorySanitizer

option(CLANG_MSAN "Enable Clang MemorySanitizer"    OFF)
if (CLANG_MSAN)
  message(STATUS "Using Clang MemorySanitizer")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitize=memory -fsanitize-memory-track-origins \
                                          -fno-omit-frame-pointer -fno-optimize-sibling-calls")

  set(CMAKE_POSITION_INDEPENDENT_CODE ON)
endif()

# }}}
# {{{ usan: Clang UndefinedBehaviorSanitizer

option(CLANG_USAN "Enable Clang UndefinedBehaviorSanitizer" OFF)
if (CLANG_USAN)
  message(STATUS "Using Clang UndefinedBehaviorSanitizer")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitize=undefined")
endif()

# }}}
# {{{ tsan: Clang ThreadSanitizer

option(CLANG_TSAN "Enable Clang ThreadSanitizer"    OFF)
if (CLANG_TSAN)
  message(STATUS "Using Clang ThreadSanitizer")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIE -fsanitize=thread")
  set(CMAKE_POSITION_INDEPENDENT_CODE ON)
endif()

# }}}
# {{{ csan: Clang CoverageSanitizer

option(CLANG_CSAN "Enable Clang CoverageSanitizer"    OFF)
if (CLANG_CSAN)
  message(STATUS "Using Clang CoverageSanitizer")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitize-coverage=func -fsanitize-coverage=edge")
endif()

# }}}
# {{{ coverage

if (CMAKE_BUILD_TYPE STREQUAL "Debug")
  include(cmake/CodeCoverage.cmake)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g -O1 -fprofile-arcs -ftest-coverage")
  setup_target_for_coverage (
    coverage
    ""
    ./coverage
  )
endif()

# }}}
# }}}
# {{{ Third Parties
# {{{ GoogleTest

find_package(Threads REQUIRED)

# TODO: use git instead of third_party submodule
ExternalProject_Add(
  googletest
  PREFIX          ${CMAKE_BINARY_DIR}/CMakeFiles/googletest
  SOURCE_DIR      ${CMAKE_SOURCE_DIR}/third_party/googletest/googletest
  CMAKE_ARGS      -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
                  -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
                  -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
                  -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
  INSTALL_COMMAND ""
)

ExternalProject_Get_Property(googletest source_dir binary_dir)

add_library(libgtest IMPORTED STATIC GLOBAL)
add_dependencies(libgtest googletest)
set_target_properties(libgtest PROPERTIES
  IMPORTED_LOCATION "${binary_dir}/libgtest.a"
  IMPORTED_LINK_INTERFACE_LIBRARIES "${CMAKE_THREAD_LIBS_INIT}"
)

add_library(libgtest_main IMPORTED STATIC GLOBAL)
add_dependencies(libgtest_main googletest)
set_target_properties(libgtest_main PROPERTIES
  IMPORTED_LOCATION "${binary_dir}/libgtest_main.a"
  IMPORTED_LINK_INTERFACE_LIBRARIES "${CMAKE_THREAD_LIBS_INIT}"
)

include_directories("${source_dir}/include")

message(STATUS "Using googletest framework")
message(STATUS "Googletest binary: ${binary_dir}")
message(STATUS "Googletest source: ${source_dir}")

# }}}
# }}}
# {{{ Compilation Flags

add_compile_options (
 -std=c++14
# Warnings
 -Wall
 -Wextra
 -Werror
 -Wcast-align
 -Wcast-qual
 -Wchar-subscripts
 -Wenum-compare
 -Wformat-nonliteral
 -Wmissing-format-attribute
 -Winit-self
 -Wmissing-declarations
 -Wmissing-include-dirs
 -Wno-error=deprecated-declarations
 -Wno-format-y2k
 -Wno-format-zero-length
 -Wno-unused-parameter
 -Wparentheses
 -Wpointer-arith
 -Wredundant-decls
 -Wsequence-point
 -Wshadow
 -Wsign-compare
 -Wswitch-default
 -Wuninitialized
 -Wunused
 -Wwrite-strings
# Auto vectorization
 -ftree-vectorize
# Formating
 -fshow-column
 -fdiagnostics-show-option
 -fdiagnostics-color=always
 -funsigned-char
 -fno-strict-aliasing
# Code Generation Convention
 -fwrapv

 -pedantic
 )

 # }}}
 # {{{ Helper Functions

 # cpp_add_test()
 #    Creates 2 test executable:
 #        * 1 that will be used by CTest to run all the tests
 #        * 1 that will be copied where the test sources are in order to
 #          easily run the test from a terminal.
 #          All the test executable that will be copied will be name ctest
 #          Example:
 #                valgrind ./ctest
 #                perf ./ctest
 #                ./ctest args
 #
 # Param NAME         The name of the test
 # Param PATH         The path of the sources of the test
 # Param SOURCES      The list of files required by the test executable
 # Param TEST_LIB     The libraries that are under tests
 # Param EXTERNAL_LIB The libraries that are needed to link the executable
function(cpp_add_test)
   set (options OPTIONAL)
   set (oneValueArgs NAME PATH)
   set (multiValueArgs SOURCES TEST_LIB EXTERNAL_LIB)
   cmake_parse_arguments(test
      "${options}"
      "${oneValueArgs}"
      "${multiValueArgs}"
       ${ARGN}
   )
   message (STATUS "Adding a new test: ${test_NAME}")
   message (STATUS "Path: ${test_PATH}")
   message (STATUS "Sources: ${test_SOURCES}")
   message (STATUS "Libraries: ${test_TEST_LIB}")
   message (STATUS "ThirdParties: ${test_EXTERNAL_LIB}")
   add_executable (${test_NAME} ${test_SOURCES})
   target_link_libraries (${test_NAME}
      -Xlinker --whole-archive ${test_TEST_LIB}
      -Xlinker --no-whole-archive ${test_EXTERNAL_LIB}
   )
   set (CMAKE_RUNTIME_OUTPUT_DIRECTORY ${test_PATH})
   cmake_policy (SET CMP0002 OLD)
   add_executable (ctest ${test_SOURCES})
   cmake_policy (SET CMP0002 NEW)
   target_link_libraries (ctest
      -Xlinker --whole-archive ${test_TEST_LIB}
      -Xlinker --no-whole-archive ${test_EXTERNAL_LIB}
   )
   add_test (
      NAME ${test_NAME}
      COMMAND ${test_NAME}
   )
endfunction(cpp_add_test)

# cpp_add_lib()
#   Creates a new library
#
# Param NAME The name of the library (usually the same as the project)
# Param PATH The path of the sources of the lib
# Param SOURCES The list of source file required by the lib
# Param TEST True if the lib has some test in a test folder
function(cpp_add_lib)
  set (options OPTIONAL)
  set (oneValueArgs NAME TEST PATH INTERNAL_DEP)
  set (multiValueArgs SOURCES)
  cmake_parse_arguments(lib
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
     ${ARGN}
   )
  message (STATUS "Adding a new lib: ${lib_NAME} (tested: ${lib_TEST})")

  project(${lib_NAME})
  include_directories(${lib_PATH}/include)
  include_directories(${lib_PATH}/)
  #include_directories(${lib_INTERNAL_DEP})
  #if (${lib_INTERNAL_DEP})
  #  include_directories(${${lib_INTERNAL_DEP}_SOURCE_DIR}/include)
  #  message (STATUS "${${lib_INTERNAL_DEP}_SOURCE_DIR}/include")
  #endif()
  add_library(${lib_NAME} STATIC ${lib_SOURCES})
  target_link_libraries(${lib_NAME})
  add_subdirectory(${lib_TEST})
endfunction(cpp_add_lib)

# }}}

include (CTest)

add_custom_target(valgrind_all_multithreaded
   COMMAND ctest --output-on-failure -j 4 -D ExperimentalMemCheck
)

add_custom_target(valgrind
   COMMAND ctest --output-on-failure -D ExperimentalMemCheck
)

add_subdirectory(src)
