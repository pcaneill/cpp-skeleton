cmake_minimum_required(VERSION 3.0.2)

include(cmake/HunterGate.cmake)
HunterGate(
    URL "https://github.com/ruslo/hunter/archive/v0.14.29.tar.gz"
    SHA1 "9c29c30fff99b7c1479b2e9d4926dcc3f8d364e0"
)

project(cppskeleton)

include(cmake/CppSkeleton.cmake)
include(cmake/CppCompilationFlags.cmake)

add_subdirectory(src)
