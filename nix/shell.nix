{
  pkgs ? <nixpkgs> { }
}:
let
  llvmVersion = "20";
  gccVersion = "15";
in
pkgs.mkShell.override { stdenv = pkgs."llvmPackages_${llvmVersion}".libcxxStdenv; } {
  # There is an open issue regarding building libc++ std module
  # with `FORTIFY_SOURCE` flag which is enabled by default.
  #
  # See:
  # https://github.com/llvm/llvm-project/issues/121709
  # https://nixos.wiki/wiki/C#Hardening_flags
  # https://nixos.org/manual/nixpkgs/stable/#fortify
  #
  # Note: only required for clang/libc++
  hardeningDisable = [ "fortify" ];

  nativeBuildInputs = [
    (pkgs."llvmPackages_${llvmVersion}".clang-tools.override { enableLibcxx = true; })
    pkgs."llvmPackages_${llvmVersion}".libcxxClang
    pkgs."gcc${gccVersion}"

    (pkgs.callPackage ./cmake-importstd-patched/package.nix { })

    pkgs.ninja
  ];

  shellHook = ''
    # workaround required for cmake to find clang manifest (allowing import std)
    # see https://github.com/NixOS/nixpkgs/issues/370217#issuecomment-2660926816
    NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -B${pkgs."llvmPackages_${llvmVersion}".libcxxClang.libcxx}/lib";
  '';
}
