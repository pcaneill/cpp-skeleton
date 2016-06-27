project(lib1)

file (GLOB_RECURSE SRC sub1/*.cpp sub2/*.cpp)
file (GLOB TESTS_SRC test/*.cpp)

cpp_add_lib(
  NAME lib1
  TEST test
  PATH ${lib1_SOURCE_DIR}
  SRC ${SRC}
  TEST_SRC ${TESTS_SRC}
)
