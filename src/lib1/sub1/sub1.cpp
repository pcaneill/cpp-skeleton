#include <lib1/sub1/public_sub1.hpp>

#include <sub1/private_sub1.hpp>

#include <iostream>

namespace lib1 {
namespace sub1 {

void private_display()
{
  std::cout << "Private display sub1" << std::endl;
}

void public_display()
{
  std::cout << "Public display sub1" << std::endl;
}
}
}
