cmake_minimum_required(VERSION 3.0.2)
project(cppskeleton)

include(cmake/CppToolchain.cmake)
include(cmake/CppSkeleton.cmake)

include(ExternalProject)

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

include (CTest)

add_custom_target(valgrind_all_multithreaded
   COMMAND ctest --output-on-failure -j 4 -D ExperimentalMemCheck
)

add_custom_target(valgrind
   COMMAND ctest --output-on-failure -D ExperimentalMemCheck
)

add_subdirectory(src)
