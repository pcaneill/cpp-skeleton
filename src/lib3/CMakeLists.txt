project (lib3)

# Test
#  * Test the existence of an include directory

cpp_add_lib (
  NAME lib3
  TEST test
  PATH "${lib3_SOURCE_DIR}"
  SRC  main.cpp
  TEST_SRC test/test.cpp
)
