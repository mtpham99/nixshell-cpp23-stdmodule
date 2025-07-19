{
  description = "nix-shell for c++23 import std support";

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
