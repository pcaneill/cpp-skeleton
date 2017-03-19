cmake_minimum_required (VERSION 3.0.2)

include (cmake/HunterGate.cmake)
HunterGate (
    URL "https://github.com/ruslo/hunter/archive/v0.18.21.tar.gz"
    SHA1 "e3a30899f43f479e900293d69f26d255a42fa3ab"
)

project (cppskeleton)

include (cmake/CppSkeleton.cmake)
include (cmake/CppCompilationFlags.cmake)

add_subdirectory (src)
