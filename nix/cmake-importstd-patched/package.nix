# Manually patch/add cmake modules required for gcc `import std` support.
# Avoids needing to rebuild cmake derivation/package.
#
# Cmake commit adding gcc import std support
# See: https://gitlab.kitware.com/cmake/cmake/-/commit/a980dab9b1a3514b3eae68cfb34806b263dc6bc3
#
# Note: this patch should not be needed after nixpkgs updates cmake to 4.0.3
# See: cmake update pr https://github.com/NixOS/nixpkgs/pull/394444
{
  lib,
  cmake,
  fetchurl,
  symlinkJoin,
}:
let
  cmakeVersion = "${lib.versions.majorMinor cmake.version}";

  cmakeGnuImportStdPath = "share/cmake-${cmakeVersion}/Modules/Compiler/GNU-CXX-CXXImportStd.cmake";
  cmakeGnuImportStdModuleFile = fetchurl {
    name = "cmake-GNUCXXImportStd-ModuleFile";
    url = "https://raw.githubusercontent.com/Kitware/CMake/a980dab9b1a3514b3eae68cfb34806b263dc6bc3/Modules/Compiler/GNU-CXX-CXXImportStd.cmake";
    hash = "sha256-zPgTIs/hqkoAbTEXhuLC9S963dnQQvefH82YCvtwAuU=";
  };

  cmakeDetermineCompilerIdModulePath = "share/cmake-${cmakeVersion}/Modules/CMakeDetermineCompilerId.cmake";
  cmakeDetermineCompilerIdModuleFile = fetchurl {
    name = "cmake-CMakeDetermineCompilerId-ModuleFile";
    url = "https://raw.githubusercontent.com/Kitware/CMake/a980dab9b1a3514b3eae68cfb34806b263dc6bc3/Modules/CMakeDetermineCompilerId.cmake";
    hash = "sha256-ERHCHdS2pL5IYgR/wxmVt0FNV8YSshw0q8inzao4xGg=";
  };
in
symlinkJoin {
  name = "${cmake.name}-importstd-patched";
  paths = [ cmake ];
  postBuild = ''
    # copy binaries to avoid using original derivation
    for link in $(find $out/bin/ -type l); do
      cp --remove-destination $(readlink $link) $out/bin/
    done;

    # symlink GNU-CXX-CXXImportStd module
    ln -s "${cmakeGnuImportStdModuleFile}" $out/${cmakeGnuImportStdPath}

    # symlink DetermineCompilerId module
    ln -sf "${cmakeDetermineCompilerIdModuleFile}" $out/${cmakeDetermineCompilerIdModulePath}
  '';
}
