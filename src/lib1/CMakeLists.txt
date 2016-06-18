project(lib1)

file (GLOB_RECURSE SRC sub1/*.cpp sub2/*.cpp)

cpp_add_lib(
  NAME lib1
  TEST test
  PATH ${lib1_SOURCE_DIR}
  SOURCES ${SRC}
)
