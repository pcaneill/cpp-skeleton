# TODO: use function
#function clean_directory()
#{
#    rm -rf ./CMakeFiles
#    rm -rf ./CMakeCache.txt
#    rm -rf ./cmake_install.cmake
#    rm -rf Makefile
#}

make clean
rm -rf ./CMakeFiles
rm -rf ./CMakeCache.txt
rm -rf ./cmake_install.cmake
rm -rf Makefile
cd src
rm -rf ./CMakeFiles
rm -rf ./CMakeCache.txt
rm -rf ./cmake_install.cmake
rm -rf Makefile
cd test
rm -rf ./CMakeFiles
rm -rf ./CMakeCache.txt
rm -rf ./cmake_install.cmake
rm -rf Makefile
cd ../../
cd ./third_party/googletest/googletest
rm -rf ./CMakeFiles
rm -rf ./CMakeCache.txt
rm -rf ./cmake_install.cmake
rm -rf Makefile
