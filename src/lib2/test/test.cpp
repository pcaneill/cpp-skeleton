#include <lib1/sub1/public_sub1.hpp>
#include <lib2/main.hpp>

/* {{{ Tests */

#include <gtest/gtest.h>

namespace test2 {

TEST (TestShared, test1)
{
  lib2::display ();
  lib1::sub1::public_display ();
  ASSERT_TRUE (true);
}

}

/* }}} */
