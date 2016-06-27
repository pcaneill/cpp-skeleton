project(lib2)

set(SRC main.cpp)

cpp_add_lib(
  NAME lib2
  TEST test
  PATH "${lib2_SOURCE_DIR}"
  SOURCES ${SRC}
  INTERNAL_DEP lib1
)
