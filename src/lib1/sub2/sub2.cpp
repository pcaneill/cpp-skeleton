#include <lib1/sub2/public_sub2.hpp>

#include <sub2/private_sub2.hpp>

#include <iostream>

namespace lib1 {
namespace sub2 {

void private_display()
{
  std::cout << "Private display sub2" << std::endl;
}

void public_display()
{
  std::cout << "Public display sub2" << std::endl;
}
}
}
