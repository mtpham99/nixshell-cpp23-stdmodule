{
  pkgs ? import <nixpkgs> { },
}:
let
  # Dummy/patch derivation (copied cmake derivation) to patch the `import std`
  # cmake module.
  # Copy existing derivation to avoid having to rebuild package from source.
  # E.g. rather than using overlay or overrideAttr to add patch.
  #
  # 1. https://github.com/NixOS/nixpkgs/issues/370217
  # 2. https://gitlab.kitware.com/cmake/cmake/-/issues/25965#note_1523575
  patched-cmake = pkgs.stdenv.mkDerivation {
    name = "cmake-patched";
    version = "0.1.0";

    buildCommand = ''
      cp -ar --no-preserve=mode ${pkgs.cmake} $out
      chmod +x $out/bin/*
      sed -i 's#libc++.modules.json#${pkgs.llvmPackages.libcxx}/lib/libc++.modules.json#' $out/share/cmake-*/Modules/Compiler/Clang-CXX-CXXImportStd.cmake
    '';
  };
in
pkgs.mkShell.override { stdenv = pkgs.llvmPackages.libcxxStdenv; } {
  # There is an open issue regarding building the std module
  # with `FORTIFY_SOURCE`
  #
  # https://github.com/llvm/llvm-project/issues/121709
  # https://nixos.wiki/wiki/C#Hardening_flags
  # https://nixos.org/manual/nixpkgs/stable/#fortify
  hardeningDisable = [ "fortify" ];

  nativeBuildInputs = [
    (pkgs.llvmPackages.clang-tools.override { enableLibcxx = true; })
    patched-cmake
    pkgs.ninja
  ];
}
