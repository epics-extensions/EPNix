{
  description = "A Nix flake containing EPICS-related modules and packages";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    with flake-utils.lib;
    (eachSystem defaultSystems (system:
      let
        overlay = import ./pkgs;
        pkgs = import nixpkgs.outPath { inherit system; overlays = [ overlay ]; };
      in
      rec {

        packages = flattenTree (pkgs.recurseIntoAttrs { inherit (pkgs) epics; });

        lib = pkgs.epnixLib;

        epnixDistribution = configuration: import ./modules {
          inherit configuration pkgs;
          epnixLib = lib;
        };

        checks = {
          top-simple = pkgs.callPackage ./test/top-simple { };
          base-build = (epnixDistribution {
            epnix = {
              support.asyn.enable = true;
              applications.apps = [ ./test/top-simple/myExampleApp ];
              boot.iocBoots = [ ./test/top-simple/iocBoot/iocmyExample ];
            };
          }).build;
        };

        /*
        checks = {
          base-source = (epnixDistribution {
            epnix.support.asyn.enable = true;
          }).source;
        };
        */
      }));
}
