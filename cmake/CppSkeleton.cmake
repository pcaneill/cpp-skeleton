include(cmake/CppToolchain.cmake)

include(ExternalProject)

include(cmake/third_party/GoogleTest.cmake)

# {{{ Add Test

 # cpp_add_test()
 #    Creates 2 test executable:
 #        * 1 that will be used by CTest to run all the tests
 #        * 1 that will be copied where the test sources are in order to
 #          easily run the test from a terminal.
 #          All the test executable that will be copied will be name ctest
 #          Example:
 #                valgrind ./ctest
 #                perf ./ctest
 #                ./ctest args
 #
 # Param NAME         The name of the test
 # Param PATH         The path of the sources of the test
 # Param SRC          The list of files required by the test executable
 # Param LIB          The libraries that are under tests
 # Param INTERNAL_DEP The libraries that are internal to the project that are
 #                    needed to link the executable
 # Param EXTERNAL_DEP The thirdparties that are needed to link the executable
function(cpp_add_test)
   set (options OPTIONAL)
   set (oneValueArgs NAME PATH)
   set (multiValueArgs SRC LIB EXTERNAL_DEP INTERNAL_DEP)
   cmake_parse_arguments(test
      "${options}"
      "${oneValueArgs}"
      "${multiValueArgs}"
       ${ARGN}
   )
   message (STATUS "Adding a new test: ${test_NAME}")
   message (STATUS "Path: ${test_PATH}")
   message (STATUS "Sources: ${test_SRC}")
   message (STATUS "Libraries: ${test_LIB}")
   message (STATUS "InternalDep: ${test_INTERNAL_DEP}")
   message (STATUS "ThirdParties: ${test_EXTERNAL_DEP}")

   add_executable (${test_NAME} ${test_SRC})
   target_link_libraries (${test_NAME}
      -Xlinker --whole-archive  ${test_LIB}
      -Xlinker --no-whole-archive ${test_INTERNAL_DEP} ${test_EXTERNAL_DEP}
                                  libgtest libgtest_main
   )

   add_custom_command(
      TARGET ${test_NAME}
      POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:${test_NAME}> "${test_PATH}/ctest"
   )
   set_directory_properties(PROPERTY ADDITIONAL_MAKE_CLEAN_FILES ${test_PATH}/ctest)

   add_test (
      NAME ${test_NAME}
      COMMAND ${test_NAME}
   )
endfunction(cpp_add_test)

# }}}
# {{{ Add lib

# cpp_add_lib()
#   Creates a new library
#
# Param NAME The name of the library (usually the same as the project)
# Param PATH The path of the sources of the lib
# Param SRC The list of source file required by the lib
# Param TEST_SRC The list of source file which test the library
function(cpp_add_lib)
  set (options OPTIONAL)
  set (oneValueArgs NAME PATH)
  set (multiValueArgs SRC TEST_SRC INTERNAL_DEP EXTERNAL_DEP)
  cmake_parse_arguments(lib
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
     ${ARGN}
   )
  message (STATUS "Adding a new lib: ${lib_NAME}")

  project(${lib_NAME})

  # TODO Can we get automatically the current path?
  include_directories(${lib_PATH}/include)
  include_directories(${lib_PATH}/)

  # TODO for_each
  if (lib_INTERNAL_DEP)
    include_directories(${${lib_INTERNAL_DEP}_SOURCE_DIR}/include)
  endif()

  add_library(${lib_NAME} STATIC ${lib_SRC})
  target_link_libraries(${lib_NAME})
  cpp_add_test(
    NAME "${lib_NAME}_test"
    PATH "${lib_PATH}/test"
    SRC "${lib_TEST_SRC}"
    LIB "${lib_NAME}"
    INTERNAL_DEP "${lib_INTERNAL_DEP}"
    EXTERNAL_DEP "${lib_EXTERNAL_DEP}"
  )
endfunction(cpp_add_lib)

function(cpp_add_lib_glob)
  set (options OPTIONAL)
  set (oneValueArgs NAME PATH)
  set (multiValueArgs SRC_PATTERN SRC_TEST_PATTERN INTERNAL_DEP EXTERNAL_DEP)
  cmake_parse_arguments(lib
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
     ${ARGN}
  )

 file(GLOB_RECURSE SRC ${lib_SRC_PATTERN})
 file(GLOB_RECURSE TEST_SRC ${lib_SRC_TEST_PATTERN})

 message (STATUS "SRC ${SRC}")
 message (STATUS "TEST_SRC ${TEST_SRC}")

 cpp_add_lib(
   NAME ${lib_NAME}
   PATH ${lib_PATH}
   SRC ${SRC}
   TEST_SRC ${TEST_SRC}
   INTERNAL_DEP ${lib_INTERNAL_DEP}
   EXTERNAL_DEP ${lib_EXTERNAL_DEP}
 )
endfunction(cpp_add_lib_glob)

# }}}
