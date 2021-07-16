{
  description = "A Nix flake containing EPICS-related modules and packages";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    with flake-utils.lib;
    (eachSystem defaultSystems (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
      rec {

        packages = flattenTree (import ./pkgs { inherit pkgs; });

        lib = import ./lib { inherit pkgs; inherit (pkgs) lib; };

        epnixDistribution = configuration: import ./modules {
          inherit configuration pkgs;
          epnixPkgs = packages;
          epnixLib = lib;
        };

        checks = {
          base-source = (epnixDistribution {
            epnix.support.asyn.enable = true;
          }).source;

          base-build = (epnixDistribution {
            epnix.support.asyn.enable = true;
          }).build;
        };
      }));
}
