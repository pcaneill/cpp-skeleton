project (lib1_test)

file (GLOB TESTS_SRC  *.cpp)

cpp_add_test (
   NAME lib1_test
   PATH ${lib1_test_SOURCE_DIR}
   SOURCES ${TESTS_SRC}
   TEST_LIB lib1
)
