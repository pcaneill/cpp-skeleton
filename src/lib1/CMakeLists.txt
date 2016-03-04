project(lib1)

include_directories(${lib1_SOURCE_DIR}/include/)
include_directories(${lib1_SOURCE_DIR}/)

file (GLOB_RECURSE SRC sub1/*.cpp sub2/*.cpp)

add_library (lib1 STATIC ${SRC})
target_link_libraries(lib1)

add_subdirectory(test)

