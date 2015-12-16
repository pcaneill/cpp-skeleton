./build_tests/normal.sh normal
./build_tests/normal.sh asan
./build_tests/normal.sh usan
./build_tests/normal.sh debug
./build_tests/normal.sh release
make P=analyzer
