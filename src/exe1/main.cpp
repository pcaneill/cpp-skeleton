#include <lib1/sub1/public_sub1.hpp>
#include <lib2/main.hpp>

int main ()
{
  lib2::display();
  lib1::sub1::public_display();

  return 0;
}
