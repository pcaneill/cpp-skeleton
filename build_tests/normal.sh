# TODO stop at first error
# Fresh start
make P=$1 clean
# Compile once everything and run the tests
make P=$1
make P=$1 test

# Run the tests manually
./src/lib1/test/ctest
./src/lib2/test/ctest

# TODO: find a way to check that the file has been compiled
# Touch a file to test incremental build
cd src/lib1/
touch sub1/sub1.cpp
make P=$1
make P=$1 test

# Touch the test file to check incremental build, compile & run tests
cd test/
touch test.cpp
make P=$1
make P=$1 test

cd ../../../

touch src/lib1/include/lib1/sub1/public_sub1.hpp
make P=$1

make distclean
