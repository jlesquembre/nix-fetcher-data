# nix-fetcher-data

> leave data alone

Rich Hickey -
[Simple Made Easy](https://www.infoq.com/presentations/Simple-Made-Easy)

## Usage

In `flake.nix`:

```nix
{
  inputs.nix-fetcher-data = {
    url = "github:jlesquembre/nix-fetcher-data";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nix-fetcher-data, nixpkgs, ... }@inputs:

    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ nix-fetcher-data.overlays.default ];
      };
    in
    {
      # ...
    };
}
```

In a derivation:

```nix
{ stdenv
, nix-package-updater
, srcFromJson
, writeScriptBin
}:

let projectInfo = srcFromJson ./src.json; in

stdenv.mkDerivation {

  inherit (projectInfo) version src;

  passthru.updateScript = writeScriptBin "update-src"
    ''
      ${nix-package-updater} pkgs/foo/src.json
    '';
}
```

`src.json` looks like this:

```json
{
  "version": "1.0",
  "fetcher": "fetchFromGitHub",
  "args": {
    "owner": "owner",
    "repo": "repo",
    "rev": "v1.0",
    "hash": "sha256-7YmJ2QHIabBu3C2kaLplxMXg9YP2KQ3OxYyFCVFOCsk=",
    "fetchSubmodules": true
  }
}
```

To update the version run `nix run .#my-pkg.update-src`
