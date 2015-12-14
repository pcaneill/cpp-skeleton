make
make test
cd build/normal
./src/lib1/test/lib1_test
cd ../../src/lib1/
touch main.cpp
cd ../../build/normal/src/lib1
make
make test
cd ../../../../src/lib1/test
touch test.cpp
cd ../../../build/normal/src/lib1/test
make
make test
./lib1_test
