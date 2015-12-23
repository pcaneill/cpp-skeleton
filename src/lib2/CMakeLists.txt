project(lib2)

include_directories(${lib2_SOURCE_DIR}/include/
                    ${lib1_SOURCE_DIR}/include/)

set(SRC main.cpp)
add_library (lib2 STATIC ${SRC})
target_link_libraries(lib2)

add_subdirectory(test)

