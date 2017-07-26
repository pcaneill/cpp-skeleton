# C++ skelton

[![build status](https://git.moeryn.com/Moeryn/cppskeleton/badges/master/build.svg)](https://git.moeryn.com/Moeryn/cppskeleton/commits/master)
[![coverage report](https://git.moeryn.com/Moeryn/cppskeleton/badges/master/coverage.svg)](https://git.moeryn.com/Moeryn/cppskeleton/commits/master)

## Why?

Have a complete ready to go C/C++ for small and personal projects that can be
easily updated in order to have all projects inherits from the new features.


## Features

* Tests

    - UnitTest with GoogleTest:

         + "make test" will run all the available unit tests.
         + For each test directory, the test program is copied and renamed
           "ctest" in order to easily run "gdb" or "valgrind" for example.


* Static Analysis

    - ClangAnalyzer

* Sanitizers:

    - AdressSanitizer
    - MemorySanitizer
    - ThreadSanitizer
    - UndefinedBehaviorSanitizer
    - Valgrind

* Coverage

* IDE features:

    - YouCompleteMe
    - rtags
    - ctags

## Strict Project Architecture

Some cmake function have been written to easily create a new library:

   - cpp_add_lib
   - cpp_add_exe

The idea is for *user* to write as less as cmake as possible.

    src/
     |--- lib1
     |     |--- include
     |     |     |--- lib1
     |     |           |--- subdirectory1
     |     |           |     |--- public_header.hpp
     |     |           |--- subdirectory2
     |     |                 |--- public_header.hpp
     |     |--- test
     |     |     |--- test.hpp
     |     |     |--- test.cpp
     |     |--- subdirectory1
     |     |     |--- private_header.hpp
     |     |     |--- files.cpp
     |     |--- subdirectory2
     |     |     |--- private_header.hpp
     |     |     |--- files.cpp
     |     |--- CMakeLists.txt
     |
     |--- lib2
     |     |--- include
     |     |     |--- lib2
     |     |           |--- public_header.hpp
     |     |--- test
     |     |     |--- test.hpp
     |     |     |--- test.cpp
     |     |--- private_header.hpp
     |     |--- files.cpp
     |     |--- CMakeLists.txt
     |--- CMakeLists

Example of header inclusion in the test directory of the lib1:

    #include <lib1/subdirectory1/public_header.hpp"
    #include <subdirectory1/public_header.hpp"
    #include <test/test.hpp"


## Targets

The following target can be used with a profile:

   - make test : Run all the unit tests.
   - make clean : clean the artifacts of one profile.
   - make valgrind : Run all the unit tests under valgrind.
                     It is advised not to use coverage and asan profile at
                     the same time.
   - make coverage : Run all the unit tests and create a coverage report.
                     Works only with release, debug and normal profile.

The following target do not need a profile:

   - make distclean : clean the artrifacts of all the profiles.
   - make ycm : Setup the ycm_extra_conf.py for YouCompleteMe.
   - make ctags : Create a ctags flag that can be use directly in vim.
   - make etags : Create a ctags flag that can be use directly in emacs.
   - make rtags : Setup rtags and feed rc with the compilation database.
   - make tidy : Run clang-tidy on all the codeline.
   - make format : Run clang-format on all the codeline.
   - make git-format : Run clang-format only on the the staged diff
     (make git-format -h for help)


## Profiles


Example:

    make PROFILE=normal test
    make P=normal tidy

   - normal : no specific compilation flag
   - debug : "Debug" cmake build type
   - release : "Release" cmake build type
   - asan : Adress Sanitizer
   - msan : Memory Sanitizer
   - tsan : Thread Sanitizer
   - usan : Undefined Behavior Sanitizer
   - analyzer : Run Clang Static Analyzer on all the codeline

## Build Configuration

Some variable can be modified in the cmake/base.mk :

   - v/build : path where the artifacts will be built
   - v/generator : cmake generator
   - v/release : release configuration
   - v/debug : debug configuration

## Parallel compilation

If the OS is Mac or Linux the number of core available will be detected
automatically.  To override the value found  set 'J' or 'JOBS' to the number of jobs.

    make J=12

## cppskeleton Developpment

- make VERBOSE=1

The project have *some* unit tests in order to catch regressions, you can run it by calling:

    python build_tests/test.py run-all

