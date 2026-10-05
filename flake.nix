{
  description = "Data. Please.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:

    let
      inherit (nixpkgs.lib) genAttrs;

      eachSystem = f: genAttrs
        [
          "aarch64-darwin"
          "x86_64-linux"
        ]
        (system: f nixpkgs.legacyPackages.${system});
    in
    {
      legacyPackages = eachSystem (pkgs: {
        srcFromJson = pkgs.callPackage ./lib { };
      });

      packages = eachSystem (pkgs: {
        default = pkgs.callPackage ./pkgs { };
      });

      overlays.default = final: prev: {
        srcFromJson = prev.callPackage ./lib { };
        nix-package-updater = prev.callPackage ./pkgs { };
      };
    };
}
