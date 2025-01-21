cmake_minimum_required(VERSION 3.30)

# https://www.kitware.com/import-std-in-cmake-3-30/
# https://github.com/Kitware/CMake/blob/v3.31.3/Help/dev/experimental.rst
set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "0e5b6991-d74f-4b3d-a41c-cf096e0b2508")
set(CMAKE_CXX_MODULE_STD ON)

project(
  hello-world
  VERSION 1.0.0
  LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS ON)

add_executable(hello-world hello-world.cpp)
