cmake_minimum_required (VERSION 3.0.2)

project (algorithm)

include(ExternalProject)

# {{{ GoogleTest

find_package(Threads REQUIRED)

ExternalProject_Add(
  googletest
  PREFIX          ${CMAKE_BINARY_DIR}/CMakeFiles/googletest
  SOURCE_DIR      ${CMAKE_SOURCE_DIR}/third_party/googletest/googletest
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
# {{{ Compilation Flags

add_compile_options (
 -std=c++14
# Warnings
 -Wall
 -Wcast-align
 -Wcast-qual
 -Wchar-subscripts
 -Wenum-compare
 -Werror
 -Wextra
 -Wformat-nonliteral
 -Wformat=2
 -Winit-self
 -Wmissing-declarations
 -Wmissing-format-attribute
 -Wmissing-include-dirs
 -Wno-error=deprecated-declarations
 -Wno-format-y2k
 -Wno-format-zero-length
 -Wno-unused-parameter
 -Wparentheses
 -Wpointer-arith
 -Wredundant-decls
 -Wredundant-decls
 -Wsequence-point
 -Wshadow
 -Wsign-compare
 -Wswitch-default
 -Wuninitialized
 -Wunused
 -Wwrite-strings
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

include_directories (include/)

# TODO: log current directory
message(STATUS "Entering src")
add_subdirectory(src)
message(STATUS "Exiting src")
