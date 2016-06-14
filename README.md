# C++ skelton

## Why?

Have a complete ready to go C/C++ for small and personal projects that can be
easily updated in order to have all projects inherits from the new features.

## Features

* Tests
    - UnitTest with GoogleTest:
         + CTest to run all the tests
         + Executable copied directly in lib/test in order to easily
           use the binary with valgrind or filtering tests.

* Static Analysis

    - ClangAnalyzer

* Sanitizers:

    - AdressSanitizer
    - MemorySanitizer
    - ThreadSanitizer
    - UndefinedBehaviorSanitizer

* Coverage with lcov

* IDE features:
    - YouCompleteMe
    - rtags
    - ctags

## Project Architecture

    src/
     |--- lib1
     |     |--- include
     |     |     |--- lib1
     |     |           |--- subdirectory1
     |     |           |     |--- public_header.hpp
     |     |           |--- subdirectory2
     |     |                 |--- public_header.hpp
     |     |--- subdirectory1
     |     |     |--- private_header.hpp
     |     |     |--- files.cpp
     |     |--- subdirectory2
     |     |     |--- private_header.hpp
     |     |     |--- files.cpp
     |     |--- test
     |     |     |--- test.hpp
     |     |     |--- test.cpp
     |
     |--- lib2


