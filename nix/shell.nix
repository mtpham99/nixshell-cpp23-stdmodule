{
  pkgs ? import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/300081d0cc72df578b02d914df941b8ec62240e6.tar.gz") { },
}:

pkgs.mkShell.override { stdenv = pkgs.llvmPackages.libcxxStdenv; } {
  # There is an open issue regarding building libc++ std module
  # with `FORTIFY_SOURCE` flag which is enabled by default
  #
  # See relevant issues:
  # https://github.com/llvm/llvm-project/issues/121709
  # https://nixos.wiki/wiki/C#Hardening_flags
  # https://nixos.org/manual/nixpkgs/stable/#fortify
  hardeningDisable = [ "fortify" ];

  nativeBuildInputs = [
    (pkgs.llvmPackages.clang-tools.override { enableLibcxx = true; })

    (pkgs.callPackage ./cmake-importstd-patched/package.nix { })

    pkgs.ninja
  ];
}
