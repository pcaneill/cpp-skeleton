cmake_minimum_required (VERSION 3.0.2)

include (cmake/HunterGate.cmake)
HunterGate(
    URL "https://github.com/ruslo/hunter/archive/v0.19.46.tar.gz"
    SHA1 "43e4edf5791a95ac845bbc5ab688b5c3ffe980af"
)

project (cppskeleton)

include (cmake/CppSkeleton.cmake)
include (cmake/CppCompilationFlags.cmake)

add_subdirectory (src)
