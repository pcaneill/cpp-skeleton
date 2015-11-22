project(lib1)

# TODO: fix glob
#set(GLOB PROJECT_SRC *.h *.hpp *.cpp)
# TODO: use GLOB_RECURSE and exclude tests like it is done in ycm

include_directories(${lib1_SOURCE_DIR}/include/)

set(SRC main.cpp)
add_library (lib1 STATIC ${SRC})
target_link_libraries(lib1)

add_subdirectory(test)

