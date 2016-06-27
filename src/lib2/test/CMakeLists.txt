project(lib2_test)

file (GLOB TESTS_SRC *.cpp)

cpp_add_test(
   NAME lib2_test
   PATH ${lib2_test_SOURCE_DIR}
   SOURCES ${TESTS_SRC}
   TEST_LIB lib2
   INTERNAL_LIB lib1
)
