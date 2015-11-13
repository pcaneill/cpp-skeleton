# TODO: fix glob
#set(GLOB TESTS_SRC *.h *.hpp *.cpp)

set(TESTS_SRC test.cpp)
add_executable (ztests ${TESTS_SRC})
target_link_libraries (ztests
    -Xlinker --whole-archive    ${PROJECT_LIB}
    -Xlinker --no-whole-archive libgtest libgtest_main
)
