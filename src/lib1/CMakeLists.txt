project (lib1)

cpp_add_lib_glob (
  NAME lib1
  PATH "${lib1_SOURCE_DIR}"
  SRC_PATTERN sub1/*.cpp sub2/*.cpp
  SRC_TEST_PATTERN test/*.cpp
)
