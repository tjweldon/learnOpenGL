cmake_minimum_required(VERSION 3.25)
project(learnOpenGL)

set(CMAKE_CXX_STANDARD 17)

#include_directories(
#        ${CMAKE_CURRENT_SOURCE_DIR}
#        /usr/local/include/assimp/
#        /usr/local/lib/
#)


add_executable(learnOpenGL main.cpp glad.c shader.h stb.cpp camera.h mesh.h model.h)
target_link_libraries(learnOpenGL glfw3 assimp)
