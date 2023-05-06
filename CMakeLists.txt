cmake_minimum_required(VERSION 3.25)
project(learnOpenGL)

set(CMAKE_CXX_STANDARD 17)


add_executable(learnOpenGL main.cpp glad.c shader.h stb.cpp)
target_link_libraries(learnOpenGL glfw3)
