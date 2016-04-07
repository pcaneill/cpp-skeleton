# C++ skelton

## Why?

When working on small libs, or small personal projects, I don't want to worry
about how I will build it.
But I still want to have all my tools (coverage, ide, sanitizers ...).
Moreover, if I take time to add a new cool feature on the build system, like for
example, the possibility to use sanitizers, I want all my project to have that
cool feature.

This is here C++ skeleton comes in:
 * One Build System
 * That updates itself.
 * That can be use in many projects

But lets not get head of ourself, I am not trying to rewrite everything from
scratch. The idea is to have a "fixed project architecture" and autogenerate
CMakeLists.txt files.

## Features

* Sanitizers:
     - AdressSanitizer
     - MemorySanitizer
     - ThreadSanitizer
     - UndefinedBehaviorSanitizer

* Coverage with lcov

* IDE:
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


