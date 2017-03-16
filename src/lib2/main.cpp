#include <iostream>

#include <lib2/main.hpp>

namespace lib2 {

void display()
{
  std::cout << "Hello World!" << std::endl;
}
}

/* {{{ Tests */

#include <gtest/gtest.h>

namespace test {

TEST(TestStatic, test2)
{
  ASSERT_TRUE(true);
}
}

/* }}} */
