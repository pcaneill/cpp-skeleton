project (lib1_test)

file (GLOB TESTS_SRC  *.cpp)

add_executable (lib1_test ${TESTS_SRC})
target_link_libraries (lib1_test
  -Xlinker --whole-archive    lib1
  -Xlinker --no-whole-archive libgtest libgtest_main
)

add_test (
  NAME lib1_test
  COMMAND lib1_test
)
