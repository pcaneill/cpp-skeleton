project(project_src_test)

# TODO: fix glob
#set(GLOB TESTS_SRC *.h *.hpp *.cpp)

include_directories(
   ${project_src_SOURCE_DIR}
   ${project_SOURCE_DIR}
)

set(TESTS_SRC test.cpp)
add_executable (ztests ${TESTS_SRC})
target_link_libraries (ztests
    -Xlinker --whole-archive    ${PROJECT_LIB}
    -Xlinker --no-whole-archive libgtest libgtest_main
)

add_test(
  NAME tests
  COMMAND ztests
)
