#include <lib1/main.hpp>
#include <lib2/main.hpp>

/* {{{ Tests */

#include <gtest/gtest.h>

namespace test2 {

TEST(TestShared, test1)
{
  lib2::display();
  lib1::display();
  ASSERT_TRUE(true);
}

}

/* }}} */
