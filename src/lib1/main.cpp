#include <iostream>

#include <lib1/main.hpp>

namespace lib1
{

void display()
{
  std::cout << "Hello World!" << std::endl;
}

}

/* {{{ Tests */

#include <gtest/gtest.h>

namespace test {

TEST(TestStatic, test4)
{
  ASSERT_TRUE(true);
}

}

/* }}} */
