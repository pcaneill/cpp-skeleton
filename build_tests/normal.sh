# TODO stop at first error
# Fresh start
make P=$1 clean
# Compile once everything and run the tests
make P=$1
make P=$1 test

# Run the tests manually
./build/$1/src/lib1/test/lib1_test
./build/$1/src/lib2/test/lib2_test

# TODO: find a way to check that the file has been compiled
# Touch a file to test incremental build
cd src/lib1/
touch main.cpp
make P=$1
make P=$1 test

# Touch the test file to check incremental build, compile & run tests
cd test/
touch test.cpp
make P=$1
make P=$1 test

cd ../../../

# Run the tests manually
./build/$1/src/lib1/test/lib1_test
./build/$1/src/lib2/test/lib2_test
