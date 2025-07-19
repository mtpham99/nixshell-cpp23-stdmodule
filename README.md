# nixshell-cpp23-stdmodule

A minimal nix-shell providing CMake w/ c++23 import std support for both clang/libc++ and gcc/libstdc++.

```cpp
import std;

auto main() -> int {
  std::cout << "Hello, World!\n";
  return 0;
}
```

## Instructions

### 1. Direct / Local

1. clone this repo

```sh
$ git clone https://github.com/mtpham99/nixshell-cpp23-stdmodule.git
```

2. enter repo and load nix shell

```sh
$ cd nixshell-cpp23-stdmodule
$ nix develop ./nix
```

3. build example

```sh
# Clang / libc++
$ CXX=clang++ cmake -G Ninja -S . -B clang-build
$ cmake --build clang-build
$ ./clang-build/hello-world

# GCC / libstdc++
$ CXX=g++ cmake -G Ninja -S . -B gcc-build
$ cmake --build gcc-build
$ ./gcc-build/hello-world
```

### 2. Flakes / Remote

If you have flakes support, you can skip the example and just load the shell environment directly:

```sh
$ nix develop github:mtpham99/nixshell-cpp23-stdmodule?dir=nix
```

This should drop you directly into the shell provided by this repo. You can confirm this by seeing which cmake package your shell is using:

```sh
$ which cmake
# /nix/store/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx-cmake-3.31.7-importstd-patched/bin/cmake
```

## Notes / About

[CMake](https://cmake.org/) has supported c++23 import std since [3.30 (see this guide)](https://www.kitware.com/import-std-in-cmake-3-30/), but only with clang/libc++. Support with gcc/libstdc++ was made available in [4.0.3](https://discourse.cmake.org/t/cmake-4-0-3-available-for-download/14242).

Some modifications are required to get both working on NixOS as nixpkgs cmake is currently on version 3.31.7 [see update pr here](https://github.com/NixOS/nixpkgs/pull/394444).

### 1. Patching CMake Modules

Cmake supports import std w/ clang/libc++ since 3.30, but gcc import std support requires cmake 4.0.3. The only changes required for this support are cmake modules added/modified in [this](https://gitlab.kitware.com/cmake/cmake/-/commit/a980dab9b1a3514b3eae68cfb34806b263dc6bc3) cmake commit.

To avoid patching the entire cmake derivation/package, which requires rebuilding cmake from source as well as other packages which depend on it, a symlink package is created to only modify the cmake modules which allows reusing the existing cmake package in nixpkgs. See [here](/nix/cmake-importstd-patched/package.nix).

This should not be required once nixpkgs updates cmake to version 4.0.3. [See update pr here](https://github.com/NixOS/nixpkgs/pull/394444).

### 2. CMake cannot find libc++.modules.json

On NixOS, cmake fails to find the `libc++.modules.json` file required for detecting std module support. See [this](https://github.com/NixOS/nixpkgs/issues/370217#issuecomment-2660926816) issue. A solution was found by [@gen740](https://github.com/gen740). [See this issue comment](https://github.com/NixOS/nixpkgs/issues/370217#issuecomment-2660926816)

### 3. Building the Libc++ Std Module

There is an [open issue](https://github.com/llvm/llvm-project/issues/121709) regarding failing to build the std module itself due to the `FORTIFY_SOURCE` C/CXX_FLAGS. These are enabled by default and need to be disabled.

**`FORTIFY_SOURCE` HAS BEEN DISABLED IN THIS SHELL, BUT IS NOT REQUIRED TO BE DISABLED IF USING GCC/LIBSTDC++**.
