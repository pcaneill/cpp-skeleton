project (exe1)

cpp_add_exe (
  NAME exe1
  PATH "${exe1_SOURCE_DIR}"
  SRC main.cpp
  INTERNAL_DEP lib1 lib2
  EXTERNAL_DEP
)

