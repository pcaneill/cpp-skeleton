#include <lib1/sub1/public_sub1.hpp>
#include <lib1/sub2/public_sub2.hpp>

#include <sub1/private_sub1.hpp>
#include <sub2/private_sub2.hpp>

#include <test/test.hpp>

#include <iostream>

/* {{{ Tests */

#include <gtest/gtest.h>

TEST(TestShared, test3)
{
  lib1::sub1::public_display ();
  lib1::sub2::public_display ();

  lib1::sub1::private_display ();
  lib1::sub2::private_display ();

  ASSERT_TRUE(true);
}

/* }}} */
