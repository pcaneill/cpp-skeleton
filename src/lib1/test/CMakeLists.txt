project(lib1_test)

# TODO: fix glob
#set(GLOB TESTS_SRC *.h *.hpp *.cpp)

set(TESTS_SRC test.cpp)
add_executable (lib1_test ${TESTS_SRC})
target_link_libraries (lib1_test
  -Xlinker --whole-archive    lib1
  -Xlinker --no-whole-archive libgtest libgtest_main
)

add_test(
  NAME lib1_test
  COMMAND lib1_test
)
