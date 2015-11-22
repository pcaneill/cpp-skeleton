#include <lib1/main.hpp>

/* {{{ Tests */

#include <gtest/gtest.h>

namespace test {

TEST(TestShared, test1)
{
  lib1::display();
  ASSERT_TRUE(true);
}

}

/* }}} */
