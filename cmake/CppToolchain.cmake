# {{{ asan: Clang AddressSanitizer

option (CLANG_ASAN "Enable Clang AddressSanitizer"   OFF)
if (CLANG_ASAN)
  message (STATUS "Using Clang AddressSanitizer")
  # add_compile_options not forwareded to external project
  set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitize=address -fno-omit-frame-pointer")
endif ()

# }}}
# {{{ msan: Clang MemorySanitizer

option (CLANG_MSAN "Enable Clang MemorySanitizer"    OFF)
if (CLANG_MSAN)
  message (STATUS "Using Clang MemorySanitizer")
  set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIE -fsanitize=memory -fsanitize-memory-track-origins -fno-omit-frame-pointer -fno-optimize-sibling-calls")
  set (CMAKE_POSITION_INDEPENDENT_CODE ON)
endif ()

# }}}
# {{{ usan: Clang UndefinedBehaviorSanitizer

option (CLANG_USAN "Enable Clang UndefinedBehaviorSanitizer" OFF)
if (CLANG_USAN)
  message (STATUS "Using Clang UndefinedBehaviorSanitizer")
  set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitizer=undefined")
endif ()

# }}}
# {{{ tsan: Clang ThreadSanitizer

option (CLANG_TSAN "Enable Clang ThreadSanitizer"    OFF)
if (CLANG_TSAN)
  message (STATUS "Using Clang ThreadSanitizer")
  set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIE -fsanitize=thread")
  set (CMAKE_POSITION_INDEPENDENT_CODE ON)
endif ()

# }}}
# {{{ csan: Clang CoverageSanitizer

option (CLANG_CSAN "Enable Clang CoverageSanitizer"    OFF)
if (CLANG_CSAN)
  message (STATUS "Using Clang CoverageSanitizer")
  set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitize-coverage=func,edge")
endif ()

# }}}
# {{{ analyzer: Clang StaticAnalyzer

option (CLANG_STATIC_ANALYZER "Enable Clang StaticAnalyzer"    OFF)
if (CLANG_STATIC_ANALYZER)
   message (STATUS "Using Clang Static analyzer")
   # TODO disable for now as it works only on fedora
   # add_compile_options(-fsyntax-only)
endif ()

# }}}
# {{{ coverage

option (LCOV_COVERAGE "Enable lcov coverage" OFF)
if (LCOV_COVERAGE)
  # {{{ License

  # Copyright (c) 2012 - 2015, Lars Bilke
  # All rights reserved.
  #
  # Redistribution and use in source and binary forms, with or without modification,
  # are permitted provided that the following conditions are met:
  #
  # 1. Redistributions of source code must retain the above copyright notice, this
  #    list of conditions and the following disclaimer.
  #
  # 2. Redistributions in binary form must reproduce the above copyright notice,
  #    this list of conditions and the following disclaimer in the documentation
  #    and/or other materials provided with the distribution.
  #
  # 3. Neither the name of the copyright holder nor the names of its contributors
  #    may be used to endorse or promote products derived from this software without
  #    specific prior written permission.
  #
  # THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  # ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  # WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  # DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
  # ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  # (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  # LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
  # ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  # (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  # SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  #
  #
  #
  # 2012-01-31, Lars Bilke
  # - Enable Code Coverage
  #
  # 2013-09-17, Joakim Söderberg
  # - Added support for Clang.
  # - Some additional usage instructions.
  #
  # USAGE:

  # 0. (Mac only) If you use Xcode 5.1 make sure to patch geninfo as described here:
  #      http://stackoverflow.com/a/22404544/80480
  #
  # 1. Copy this file into your cmake modules path.
  #
  # 2. Add the following line to your CMakeLists.txt:
  #      INCLUDE(CodeCoverage)
  #
  # 3. Set compiler flags to turn off optimization and enable coverage:
  #    SET(CMAKE_CXX_FLAGS "-g -O0 -fprofile-arcs -ftest-coverage")
  #  SET(CMAKE_C_FLAGS "-g -O0 -fprofile-arcs -ftest-coverage")
  #
  # 3. Use the function SETUP_TARGET_FOR_COVERAGE to create a custom make target
  #    which runs your test executable and produces a lcov code coverage report:
  #    Example:
  #  SETUP_TARGET_FOR_COVERAGE(
  #       my_coverage_target  # Name for custom target.
  #       test_driver         # Name of the test driver executable that runs the tests.
  #                 # NOTE! This should always have a ZERO as exit code
  #                 # otherwise the coverage generation will not complete.
  #       coverage            # Name of output directory.
  #       )
  #
  # 4. Build a Debug build:
  #  cmake -DCMAKE_BUILD_TYPE=Debug ..
  #  make
  #  make my_coverage_target
  #
  #
  # }}}

  # Check prereqs
  find_program (GCOV_PATH gcov)
  find_program (LCOV_PATH lcov)
  find_program (GENHTML_PATH genhtml )
  find_program (GOOGLE_CHROME_PATH google-chrome)
  find_program (FIREFOX_PATH firefox)
  find_program (GCOVR_PATH gcovr PATHS ${CMAKE_SOURCE_DIR}/tests)

  if (NOT GCOV_PATH)
    message (FATAL_ERROR "gcov not found! Aborting...")
  endif () # NOT GCOV_PATH

  if (NOT CMAKE_COMPILER_IS_GNUCXX)
    # Clang version 3.0.0 and greater now supports gcov as well.
    message (WARNING "Compiler is not GNU gcc! Clang Version 3.0.0 and greater supports gcov as "
      "well, but older versions don't.")

    if (NOT "${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
      message (FATAL_ERROR "Compiler is not GNU gcc! Aborting...")
    endif ()
  endif () # NOT CMAKE_COMPILER_IS_GNUCXX

  set (
    CMAKE_CXX_FLAGS_COVERAGE
    "-g -O0 --coverage -fprofile-arcs -ftest-coverage"
    CACHE STRING "Flags used by the C++ compiler during coverage builds."
    FORCE
  )
  set (
    CMAKE_C_FLAGS_COVERAGE
    "-g -O0 --coverage -fprofile-arcs -ftest-coverage"
    CACHE STRING "Flags used by the C compiler during coverage builds."
    FORCE
  )
  set (
    CMAKE_EXE_LINKER_FLAGS_COVERAGE
    ""
    CACHE STRING "Flags used for linking binaries during coverage builds."
    FORCE
  )
  set (
    CMAKE_SHARED_LINKER_FLAGS_COVERAGE
    ""
    CACHE STRING "Flags used by the shared libraries linker during coverage builds."
    FORCE
  )
  mark_as_advanced (
      CMAKE_CXX_FLAGS_COVERAGE
      CMAKE_C_FLAGS_COVERAGE
      CMAKE_EXE_LINKER_FLAGS_COVERAGE
      CMAKE_SHARED_LINKER_FLAGS_COVERAGE
  )

  if (NOT (CMAKE_BUILD_TYPE STREQUAL "Debug" OR CMAKE_BUILD_TYPE STREQUAL "Coverage"))
    message (WARNING "Code coverage results with an optimized (non-Debug) build may be misleading")
  endif () # NOT CMAKE_BUILD_TYPE STREQUAL "Debug"


  # Param _targetname     The name of new the custom make target
  # Param _testrunner     The name of the target which runs the tests.
  #           MUST return ZERO always, even on errors.
  #           If not, no coverage report will be created!
  # Param _outputname     lcov output is generated as _outputname.info
  #                       HTML report is generated in _outputname/index.html
  # Optional fourth parameter is passed as arguments to _testrunner
  #   Pass them in list form, e.g.: "-j;2" for -j 2
  function (SETUP_TARGET_FOR_COVERAGE _targetname _testrunner _outputname)

    if (NOT LCOV_PATH)
      message (FATAL_ERROR "lcov not found! Aborting...")
    endif () # NOT LCOV_PATH

    if (NOT GENHTML_PATH)
      message (FATAL_ERROR "genhtml not found! Aborting...")
    endif () # NOT GENHTML_PATH

    # Setup target
    add_custom_target (${_targetname}

      # Cleanup lcov
      ${LCOV_PATH} --directory . --zerocounters

      # Run tests
      COMMAND make && make test

      # Capturing lcov counters and generating report
      COMMAND ${LCOV_PATH} --directory . --capture --output-file ${_outputname}.info
      COMMAND ${LCOV_PATH} --remove ${_outputname}.info 'tests/*' '*/test' 'test/*' 'gtest/*' 'gtest*' '/usr/*' --output-file ${_outputname}.info.cleaned
      COMMAND ${GENHTML_PATH} -o ${_outputname} ${_outputname}.info.cleaned
      COMMAND ${CMAKE_COMMAND} -E remove ${_outputname}.info ${_outputname}.info.cleaned

      WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
      COMMENT "Resetting code coverage counters to zero.\nProcessing code coverage counters and generating report."
    )

    if (GOOGLE_CHROME_PATH)
      add_custom_command (TARGET ${_targetname} POST_BUILD
        COMMAND ${GOOGLE_CHROME_PATH} ${_outputname}/index.html;
        COMMENT "Opening ./${_outputname}/index.html."
      )
    elseif (FIREFOX)
      add_custom_command (TARGET ${_targetname} POST_BUILD
        COMMAND ${FIREFOX_PATH} ${_outputname}/index.html;
        COMMENT "Opening ./${_outputname}/index.html."
        )
    else ()
      add_custom_command (TARGET ${_targetname} POST_BUILD
        COMMAND ;
        COMMENT "Open ./${_outputname}/index.html in your browser"
      )
    endif ()

  endfunction () # SETUP_TARGET_FOR_COVERAGE

  # Param _targetname     The name of new the custom make target
  # Param _testrunner     The name of the target which runs the tests
  # Param _outputname     cobertura output is generated as _outputname.xml
  # Optional fourth parameter is passed as arguments to _testrunner
  #   Pass them in list form, e.g.: "-j;2" for -j 2
  function (SETUP_TARGET_FOR_COVERAGE_COBERTURA _targetname _testrunner _outputname)

    if (NOT PYTHON_EXECUTABLE)
      message (FATAL_ERROR "Python not found! Aborting...")
    endif () # NOT PYTHON_EXECUTABLE

    if (NOT GCOVR_PATH)
      message (FATAL_ERROR "gcovr not found! Aborting...")
    endif () # NOT GCOVR_PATH

    add_custom_target (${_targetname}

      # Run tests
      ${_testrunner} ${ARGV3}

      # Running gcovr
      COMMAND ${GCOVR_PATH} -x -r ${CMAKE_SOURCE_DIR} -e '${CMAKE_SOURCE_DIR}/tests/'  -o ${_outputname}.xml
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
      COMMENT "Running gcovr to produce Cobertura code coverage report."
    )

    # Show info where to find the report
    add_custom_command (TARGET ${_targetname} POST_BUILD
      COMMAND ;
      COMMENT "Cobertura code coverage report saved in ${_outputname}.xml."
    )

  endfunction () # SETUP_TARGET_FOR_COVERAGE_COBERTURA
  set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g -fprofile-arcs -ftest-coverage")
  # TODO not working properly see linkage
  #add_compile_options(
  #   -g
  #   -O1
  #   -fprofile-arcs
  #   -ftest-coverage
  #)
  setup_target_for_coverage (
    coverage
    ""
    ./coverage
  )
endif ()

# }}}
# {{{ test

include (CTest)

# }}}
# {{{ valgrind_all_multithreaded valgrind

add_custom_target (valgrind_all_multithreaded
   COMMAND ctest --output-on-failure -j 4 -D ExperimentalMemCheck
)

add_custom_target (valgrind
   COMMAND ctest --output-on-failure -D ExperimentalMemCheck
)

# }}}
