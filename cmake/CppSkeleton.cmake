include (cmake/CppToolchain.cmake)

#include(ExternalProject)

hunter_add_package (GTest)
find_package (GTest CONFIG REQUIRED)

# {{{ Add unit test

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
function (cpp_add_test)
  set (options OPTIONAL)
  set (oneValueArgs NAME PATH)
  set (multiValueArgs SRC LIB EXTERNAL_DEP INTERNAL_DEP)
  cmake_parse_arguments (test
     "${options}"
     "${oneValueArgs}"
     "${multiValueArgs}"
      ${ARGN}
  )
  # Logging
  message (STATUS "Adding a new test: ${test_NAME}")
  message (STATUS "    * Path: ${test_PATH}")
  message (STATUS "    * Sources: ${test_SRC}")
  message (STATUS "    * Libraries: ${test_LIB}")
  if (test_INTERNAL_DEP)
    message (STATUS "    * InternalDep: ${test_INTERNAL_DEP}")
  endif ()
  if (test_EXTERNAL_DEP)
    message (STATUS "    * ThirdParties: ${test_EXTERNAL_DEP}")
  endif ()

  add_executable (${test_NAME} ${test_SRC})
  target_link_libraries (${test_NAME}
     -Xlinker --whole-archive  ${test_LIB}
     -Xlinker --no-whole-archive ${test_INTERNAL_DEP} ${test_EXTERNAL_DEP}
                                 GTest::main
  )

  # Copying test executable to the in source test repository.
  add_custom_command (
     TARGET ${test_NAME}
     POST_BUILD
     COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:${test_NAME}> "${test_PATH}/ctest"
  )
  set_directory_properties (PROPERTY ADDITIONAL_MAKE_CLEAN_FILES ${test_PATH}/ctest)

  add_test (
     NAME ${test_NAME}
     COMMAND ${test_NAME}
  )
endfunction (cpp_add_test)

# }}}
# {{{ Add lib

# cpp_add_lib()
#   Creates a new library
#
# Param NAME The name of the library (usually the same as the project).
# Param PATH The path of the sources of the lib.
# Param SRC The list of source file required by the lib.
# Param TEST_SRC The list of source file which test the library.
# Param INTERNAL_DEP List of internal dependencies.
# Param EXTERNAL_DEP List of external dependencies.
function (cpp_add_lib)
  set (options OPTIONAL)
  set (oneValueArgs NAME PATH)
  set (multiValueArgs SRC TEST_SRC INTERNAL_DEP EXTERNAL_DEP)
  cmake_parse_arguments (lib
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
     ${ARGN}
   )
  # Logging
  message (STATUS "Adding a new lib: ${lib_NAME}")
  message (STATUS "    * Path: ${lib_PATH}")
  message (STATUS "    * Sources: ${lib_SRC}")
  if (lib_INTERNAL_DEP)
    message (STATUS "    * InternalDep: ${lib_INTERNAL_DEP}")
  endif ()
  if (lib_EXTERNAL_DEP)
    message (STATUS "    * ThirdParties: ${lib_EXTERNAL_DEP}")
  endif ()

  project (${lib_NAME})

  # TODO Can we get automatically the current path?
  if (EXISTS "${lib_PATH}/include")
   include_directories (${lib_PATH}/include)
  endif ()
  include_directories (${lib_PATH}/)

  if (lib_INTERNAL_DEP)
    foreach (libinternal IN LISTS lib_INTERNAL_DEP)
      if (EXISTS "${${libinternal}_SOURCE_DIR}/include")
        include_directories (${${libinternal}_SOURCE_DIR}/include)
        message (STATUS "    * Adding include ${${libinternal}_SOURCE_DIR}/include")
      endif ()
    endforeach ()
  endif ()

  add_library (${lib_NAME} STATIC ${lib_SRC})
  target_link_libraries (${lib_NAME} GTest::main)
  cpp_add_test (
    NAME "${lib_NAME}_test"
    PATH "${lib_PATH}/test"
    SRC "${lib_TEST_SRC}"
    LIB "${lib_NAME}"
    INTERNAL_DEP "${lib_INTERNAL_DEP}"
    EXTERNAL_DEP "${lib_EXTERNAL_DEP}"
  )
endfunction (cpp_add_lib)

# cpp_add_lib_glob()
#   Creates a new library using Glob for the sources and the tests
#
# Param NAME The name of the library (usually the same as the project).
# Param PATH The path of the sources of the lib.
# Param SRC_PATTERN The glob pattern required to fetch all sources.
# Param TEST_SRC_PATTERN The glob pattern to fetch all the tests sources.
# Param INTERNAL_DEP List of internal dependencies.
# Param EXTERNAL_DEP List of external dependencies.
function (cpp_add_lib_glob)
  set (options OPTIONAL)
  set (oneValueArgs NAME PATH)
  set (multiValueArgs SRC_PATTERN SRC_TEST_PATTERN INTERNAL_DEP EXTERNAL_DEP)
  cmake_parse_arguments (lib
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
     ${ARGN}
  )

  file (GLOB_RECURSE SRC ${lib_SRC_PATTERN})
  # The test source are part of a different target so they need to be removed
  file (GLOB_RECURSE to_remove ${lib_SRC_TEST_PATTERN})
  if (to_remove)
    list (REMOVE_ITEM SRC ${to_remove})
  endif ()
  file (GLOB_RECURSE TEST_SRC ${lib_SRC_TEST_PATTERN})

  cpp_add_lib (
    NAME ${lib_NAME}
    PATH ${lib_PATH}
    SRC ${SRC}
    TEST_SRC ${TEST_SRC}
    INTERNAL_DEP ${lib_INTERNAL_DEP}
    EXTERNAL_DEP ${lib_EXTERNAL_DEP}
  )
endfunction (cpp_add_lib_glob)

# }}}
# {{{ Add executable

# cpp_add_exe()
#   Creates an executable.
#
# Param NAME The name of the executable.
# Param PATH The path of the sources of the executable.
# Param SRC The list of the sources files.
# Param INTERNAL_DEP List of internal dependencies.
# Param EXTERNAL_DEP List of external dependencies.
function (cpp_add_exe)
  set (options OPTIONAL)
  set (oneValueArgs NAME PATH)
  set (multiValueArgs SRC INTERNAL_DEP EXTERNAL_DEP)
  cmake_parse_arguments (exe
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
     ${ARGN}
   )

  if (exe_INTERNAL_DEP)
    foreach (libinternal IN LISTS exe_INTERNAL_DEP)
      if (EXISTS "${${libinternal}_SOURCE_DIR}/include")
        include_directories (${${libinternal}_SOURCE_DIR}/include)
        message (STATUS "    * Adding include ${${libinternal}_SOURCE_DIR}/include")
      endif ()
    endforeach ()
  endif ()

  add_executable (${exe_NAME} ${exe_SRC})
  target_link_libraries (${exe_NAME} ${exe_INTERNAL_DEP} ${exe_EXTERNAL_DEP})

  # Copying executable to the bin directory.
  add_custom_command (
     TARGET ${exe_NAME}
     POST_BUILD
     COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:${exe_NAME}> "${CMAKE_SOURCE_DIR}/bin/${exe_NAME}"
     COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:${exe_NAME}> "${exe_PATH}/${exe_NAME}"
  )
  set_directory_properties (
    PROPERTIES
    ADDITIONAL_MAKE_CLEAN_FILES "${exe_PATH}/${exe_NAME};${CMAKE_SOURCE_DIR}/bin/${exe_NAME}"
  )

endfunction ()


# }}}
