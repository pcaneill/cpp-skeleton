#include <iostream>

#include <project/main.hpp>

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
