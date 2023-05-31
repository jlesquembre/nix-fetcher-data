{
  description = "Data. Please.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-part.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {

      imports =
        [
          flake-parts.flakeModules.easyOverlay
        ];
      systems = [ "x86_64-linux" "aarch64-darwin" ];

      perSystem = { config, self', inputs', pkgs, system, ... }: {

        legacyPackages.srcFromJson = pkgs.callPackage ./lib { };
        packages.default = pkgs.callPackage ./pkgs { };

        overlayAttrs = {
          inherit (config.legacyPackages) srcFromJson;
          nix-package-updater = config.packages.default;
        };

      };
    };
}
