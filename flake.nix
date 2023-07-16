{
  description = "Generate Dash compatible docsets for NixOS options.";

  inputs = rec {
    nixpkgs.url = "github:NixOS/nixpkgs/release-22.11";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
  flake-utils.lib.eachDefaultSystem (system:
    let config = {};

        pkgs =
          import nixpkgs { inherit config system; overlays = []; };

        nixos = pkgs.callPackage "${nixpkgs}/nixos/release.nix" {};

        mkDocset = args: pkgs.callPackage ./package.nix (args // {
          inherit (nixos) options;
          manual = nixos.manual.${system};
        });

        docset = mkDocset { test = false; };
        test   = mkDocset { test = true;  };

     in {
          packages = {
            inherit test docset;
            default = docset;
          };
        }
    );
}
