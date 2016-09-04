project (lib2)

set (SRC main.cpp)
file (GLOB TESTS_SRC test/*.cpp)

cpp_add_lib (
  NAME lib2
  TEST test
  PATH "${lib2_SOURCE_DIR}"
  SRC  ${SRC}
  TEST_SRC ${TESTS_SRC}
  INTERNAL_DEP lib1
)
