# nix-shell-cpp23-std-module

This was written on ***21 January 2025***.

This repo contains a minimal nix shell file (via a flake) that provides `CMake + Ninja + Clang w/ Libc++` that enables using the `c++23 std module` on NixOS.

See this guide: [link](https://www.kitware.com/import-std-in-cmake-3-30/)

<!-- ## Example -->
<!---->
<!-- Assuming you have flakes support: -->
<!---->
<!-- ```bash -->
<!---->
<!-- ``` -->

```cpp
# hello-world.cpp

import std;

auto main() -> int {
    std::cout << "Hello, World!\n";
    return 0;
}
```

## Notes / About

### 1. Patching CMake Module

Currently the setup requires patching the cmake module `Clang-CXX-CXXImportStd.cmake` for properly finding the `libc++.modules.json` manifest to determine libc++ std module support.

This is actually an issue with LLVM/Clang due to the `clang++ -print-file-name` not working properly (supposedly on MacOS + Linux). This is supposed to be patched in the most recently released LLVM 19.1.7 for MacOS, but not sure if it will also fix things for Linux. LLVM 19.1.7 is not yet merged in nixpkgs -- [pr here](https://github.com/NixOS/nixpkgs/pull/373937)).

The most simple workaround here is to patch the CMake module file directly, rather than trying to build the new LLVM release from source.

Rather than trying to patch the CMake derivation, I simply made a dummy/patch derivation where the built official CMake derivation is copied and the module file is edited. This is to prevent rebuilding the entire package from source (e.g. when trying to use `overlays` or `overrideAttrs`).

For more info see these issues:

1. [https://gitlab.kitware.com/cmake/cmake/-/issues/25965#note_1523575](https://gitlab.kitware.com/cmake/cmake/-/issues/25965#note_1523575)
2. [https://github.com/NixOS/nixpkgs/issues/370217](https://github.com/NixOS/nixpkgs/issues/370217)

### 2. Building the Libc++ Std Module

There is an [open issue](https://github.com/llvm/llvm-project/issues/121709) regarding failing to build the std module itself due to the `FORTIFY_SOURCE` C/CXX_FLAGS. These are enabled by default and need to be disabled.
