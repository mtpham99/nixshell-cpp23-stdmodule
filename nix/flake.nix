{
  description = "C++23 Std Module: CMake + Ninja + Clang";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = {self, nixpkgs} @ inputs :
  let
    system = "x86_64-linux";
    pkgs = (import nixpkgs { inherit system; });
  in
  {
      devShells."${system}".default = import ./shell.nix { inherit pkgs; };
  };
}
