project (lib1)

cpp_add_lib_glob (
  NAME lib1
  PATH "${lib1_SOURCE_DIR}"
  SRC_PATTERN *.cpp
  SRC_TEST_PATTERN test/*.cpp
)
