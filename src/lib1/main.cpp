#include <iostream>

#include <lib1/main.hpp>

void display()
{
  std::cout << "Hello World!" << std::endl;
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
