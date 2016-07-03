cmake_minimum_required(VERSION 3.0.2)
project(cppskeleton)

include(cmake/CppToolchain.cmake)
include(cmake/CppSkeleton.cmake)
include(cmake/CppCompilationFlags.cmake)

add_subdirectory(src)
