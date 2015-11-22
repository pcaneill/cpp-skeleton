project(lib2_test)

set(TESTS_SRC test.cpp)
add_executable (lib2_test ${TESTS_SRC})
target_link_libraries (lib2_test
  -Xlinker --whole-archive    lib2 lib1
  -Xlinker --no-whole-archive libgtest libgtest_main
)

add_test(
  NAME lib2_test
  COMMAND lib2_test
)
