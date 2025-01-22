# Dummy cmake package for replacing the ImportStd module.
# Symlink existing derivation to avoid rebuilding package from source.
# I.e. rather than using overlay or override(Attr) to add patch.
#
# Note this is actually a clang/llvm issue (`-print-file-name` flag not working),
# but it is much simpler to just patch the cmake module itself. Maybe fixed in llvm 19.1.7
#
# See relevant issues:
# 1. https://github.com/NixOS/nixpkgs/issues/370217
# 2. https://gitlab.kitware.com/cmake/cmake/-/issues/25965#note_1523575
{
  lib,
  cmake,
  libcxx,
  symlinkJoin,
}:
let
  cmake-ver = "${lib.versions.majorMinor cmake.version}";
  module-path = "share/cmake-${cmake-ver}/Modules/Compiler/Clang-CXX-CXXImportStd.cmake";
in
symlinkJoin {
  name = "${cmake.name}-importstd-module-patched";
  paths = [ cmake ];
  postBuild = ''
    # copy binaries to avoid using original derivation
    for link in $(find $out/bin/ -type l); do
      cp --remove-destination $(readlink $link) $out/bin/
    done;

    # replace symlink to existing module with copy for editing
    cp --remove-destination $(readlink $out/${module-path}) $out/${module-path}

    # replace "libc++.modules.json" with full path
    # to libc++ module json in new copied module file
    sed -i 's#libc++.modules.json#${libcxx}/lib/libc++.modules.json#' $out/${module-path}
  '';
}
