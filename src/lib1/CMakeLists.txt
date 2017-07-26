project (lib1)

set (HDRS
   include/lib1/sub1/public_sub1.hpp
   include/lib1/sub2/public_sub2.hpp

   sub1/private_sub1.hpp
   sub2/private_sub2.hpp
)

set (SRCS
   sub1/sub1.cpp
   sub2/sub2.cpp
)

set (TESTS
   test/test.hpp
   test/test.cpp

   test/test2.cpp
)

cpp_add_lib (
  NAME lib1
  PATH "${lib1_SOURCE_DIR}"
  SRC ${SRCS} ${HDRS}
  TEST_SRC ${TESTS}
)
