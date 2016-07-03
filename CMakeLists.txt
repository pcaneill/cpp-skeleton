cmake_minimum_required(VERSION 3.0.2)
project(cppskeleton)

include(cmake/CppToolchain.cmake)
include(cmake/CppSkeleton.cmake)
include(cmake/CppCompilationFlags.cmake)

include(ExternalProject)

include (CTest)

add_custom_target(valgrind_all_multithreaded
   COMMAND ctest --output-on-failure -j 4 -D ExperimentalMemCheck
)

add_custom_target(valgrind
   COMMAND ctest --output-on-failure -D ExperimentalMemCheck
)

add_subdirectory(src)
