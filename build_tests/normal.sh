# TODO stop at first error
# Fresh start
make P=$1 clean
# Compile once everything and run the tests
make P=$1
make P=$1 test

# Run the tests manually
cd build/$1
./src/lib1/test/lib1_test
./src/lib2/test/lib2_test

# Touch a file to test incremental build
cd ../../src/lib1/
touch main.cpp

# Try to compile
# TODO: find a way to check that the file has been compiled
cd ../../build/$1/src/lib1
make P=$1
make P=$1 test

# Touch the test file to check incremental build, compile & run tests
cd ../../../../src/lib1/test
touch test.cpp
cd ../../../build/$1/src/lib1/test
make P=$1
make P=$1 test
./lib1_test
