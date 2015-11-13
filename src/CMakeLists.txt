set(PROJECT_LIB "project")

# TODO: fix glob
#set(GLOB PROJECT_SRC *.h *.hpp *.cpp)
# TODO: use GLOB_RECURSE and exclude tests like it is done in ycm

set(PROJECT_SRC main.cpp)
add_library (${PROJECT_LIB} STATIC ${PROJECT_SRC})
target_link_libraries(${PROJECT_LIB})

# TODO: log current directory
message(STATUS "Entering test")
add_subdirectory(test)
message(STATUS "Exiting test")

