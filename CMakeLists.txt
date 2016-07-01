cmake_minimum_required(VERSION 3.0.2)

project(cppskeleton)

include(ExternalProject)

# {{{ Targets
# {{{ asan: Clang AddressSanitizer

option(CLANG_ASAN "Enable Clang AddressSanitizer"   OFF)
if (CLANG_ASAN)
  message(STATUS "Using Clang AddressSanitizer")
  add_compile_options(
     -fsanitize=address
     -fno-omit-frame-pointer
  )
endif()

# }}}
# {{{ msan: Clang MemorySanitizer

option(CLANG_MSAN "Enable Clang MemorySanitizer"    OFF)
if (CLANG_MSAN)
  message(STATUS "Using Clang MemorySanitizer")
  add_compile_options(
     -fsanitize=memory
     -fsanitize-memory-track-origins
     -fno-omit-frame-pointer
     -fno-optimize-sibling-calls
  )
  set(CMAKE_POSITION_INDEPENDENT_CODE ON)
endif()

# }}}
# {{{ usan: Clang UndefinedBehaviorSanitizer

option(CLANG_USAN "Enable Clang UndefinedBehaviorSanitizer" OFF)
if (CLANG_USAN)
  message(STATUS "Using Clang UndefinedBehaviorSanitizer")
  add_compile_options(-fsanitizer=undefined)
endif()

# }}}
# {{{ tsan: Clang ThreadSanitizer

option(CLANG_TSAN "Enable Clang ThreadSanitizer"    OFF)
if (CLANG_TSAN)
  message(STATUS "Using Clang ThreadSanitizer")
  add_compile_options(-fsanitize=thread)
  set(CMAKE_POSITION_INDEPENDENT_CODE ON)
endif()

# }}}
# {{{ csan: Clang CoverageSanitizer

option(CLANG_CSAN "Enable Clang CoverageSanitizer"    OFF)
if (CLANG_CSAN)
  message(STATUS "Using Clang CoverageSanitizer")
  add_compile_options(-fsanitize-coverage=func,edge)
endif()

# }}}
# {{{ analyzer: Clang StaticAnalyzer

option(CLANG_STATIC_ANALYZER "Enable Clang StaticAnalyzer"    OFF)
if (CLANG_STATIC_ANALYZER)
   message(STATUS "Using Clang Static analyzer")
   add_compile_options(-fsyntax-only)
endif()

# }}}
# {{{ coverage

if (CMAKE_BUILD_TYPE STREQUAL "Debug")
  include(cmake/CodeCoverage.cmake)
  add_compile_options(
     -g
     -fprofile-arcs
     -ftest-coverage
  )
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
 # Param SRC          The list of files required by the test executable
 # Param LIB          The libraries that are under tests
 # Param INTERNAL_DEP The libraries that are internal to the project that are
 #                    needed to link the executable
 # Param EXTERNAL_DEP The thirdparties that are needed to link the executable
function(cpp_add_test)
   set (options OPTIONAL)
   set (oneValueArgs NAME PATH)
   set (multiValueArgs SRC LIB EXTERNAL_DEP INTERNAL_DEP)
   cmake_parse_arguments(test
      "${options}"
      "${oneValueArgs}"
      "${multiValueArgs}"
       ${ARGN}
   )
   message (STATUS "Adding a new test: ${test_NAME}")
   message (STATUS "Path: ${test_PATH}")
   message (STATUS "Sources: ${test_SRC}")
   message (STATUS "Libraries: ${test_LIB}")
   message (STATUS "InternalDep: ${test_INTERNAL_DEP}")
   message (STATUS "ThirdParties: ${test_EXTERNAL_DEP}")

   add_executable (${test_NAME} ${test_SRC})
   target_link_libraries (${test_NAME}
      -Xlinker --whole-archive  ${test_LIB}
      -Xlinker --no-whole-archive ${test_INTERNAL_DEP} ${test_EXTERNAL_DEP}
                                  libgtest libgtest_main
   )

   add_custom_command(
      TARGET ${test_NAME}
      POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:${test_NAME}> "${test_PATH}/ctest"
   )
   set_directory_properties(PROPERTY ADDITIONAL_MAKE_CLEAN_FILES ${test_PATH}/ctest)

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
# Param SRC The list of source file required by the lib
# Param TEST_SRC The list of source file which test the library
function(cpp_add_lib)
  set (options OPTIONAL)
  set (oneValueArgs NAME PATH)
  set (multiValueArgs SRC TEST_SRC INTERNAL_DEP EXTERNAL_DEP)
  cmake_parse_arguments(lib
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
     ${ARGN}
   )
  message (STATUS "Adding a new lib: ${lib_NAME}")

  project(${lib_NAME})

  # TODO Can we get automatically the current path?
  include_directories(${lib_PATH}/include)
  include_directories(${lib_PATH}/)

  # TODO for_each
  if (lib_INTERNAL_DEP)
    include_directories(${${lib_INTERNAL_DEP}_SOURCE_DIR}/include)
  endif()

  add_library(${lib_NAME} STATIC ${lib_SRC})
  target_link_libraries(${lib_NAME})
  cpp_add_test(
    NAME "${lib_NAME}_test"
    PATH "${lib_PATH}/test"
    SRC "${lib_TEST_SRC}"
    LIB "${lib_NAME}"
    INTERNAL_DEP "${lib_INTERNAL_DEP}"
    EXTERNAL_DEP "${lib_EXTERNAL_DEP}"
  )
endfunction(cpp_add_lib)

function(cpp_add_lib_glob)
  set (options OPTIONAL)
  set (oneValueArgs NAME PATH)
  set (multiValueArgs SRC_PATTERN SRC_TEST_PATTERN INTERNAL_DEP EXTERNAL_DEP)
  cmake_parse_arguments(lib
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
     ${ARGN}
  )

 file(GLOB_RECURSE SRC ${lib_SRC_PATTERN})
 file(GLOB_RECURSE TEST_SRC ${lib_SRC_TEST_PATTERN})

 message (STATUS "SRC ${SRC}")
 message (STATUS "TEST_SRC ${TEST_SRC}")

 cpp_add_lib(
   NAME ${lib_NAME}
   PATH ${lib_PATH}
   SRC ${SRC}
   TEST_SRC ${TEST_SRC}
   INTERNAL_DEP ${lib_INTERNAL_DEP}
   EXTERNAL_DEP ${lib_EXTERNAL_DEP}
 )
endfunction(cpp_add_lib_glob)

# }}}

include (CTest)

add_custom_target(valgrind_all_multithreaded
   COMMAND ctest --output-on-failure -j 4 -D ExperimentalMemCheck
)

add_custom_target(valgrind
   COMMAND ctest --output-on-failure -D ExperimentalMemCheck
)

add_subdirectory(src)
