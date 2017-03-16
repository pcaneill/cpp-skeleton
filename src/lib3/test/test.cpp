#include <main.hpp>

/* {{{ Tests */

#include <gtest/gtest.h>

namespace test3 {

TEST(TestShared, test3)
{
  lib3::test();
  ASSERT_TRUE(true);
}
}

/* }}} */
