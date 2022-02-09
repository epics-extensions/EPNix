# TODO: leave only latest upstream supported versions of packages

{
  description = "A Nix flake containing EPICS-related modules and packages";

  inputs.bash-lib = {
    url = "github:minijackson/bash-lib";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.devshell.url = "github:numtide/devshell";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
  inputs.nix-module-doc = {
    url = "git+ssh://git@drf-gitlab.cea.fr/rnicole/nix-module-doc.git";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, bash-lib, devshell, flake-utils, nixpkgs, ... } @ inputs:
    let
      overlay = import ./pkgs self.lib;
    in
    with flake-utils.lib;
    ((eachSystem [ "aarch64-linux" "x86_64-linux" ] (system:
      let
        pkgs = import nixpkgs.outPath { inherit system; overlays = [ overlay bash-lib.overlay ]; };
      in
      rec {

        packages = flattenTree (pkgs.recurseIntoAttrs pkgs.epnix) // {
          manpage = self.lib.mkEpnixManPage system { };
          mdbook = self.lib.mkEpnixMdBook system { };
        };

        legacyPackages = pkgs;

        checks = (import ./checks { inherit pkgs; }) // {
          # The manpage and documentation should always build
          inherit (self.packages.${system}) manpage mdbook;
        };
      })) // {
      inherit overlay;

      lib = import ./lib { lib = nixpkgs.lib; inherit inputs; };

      templates.top = {
        path = ./templates/top;
        description = "An EPNix TOP project";
      };

      defaultTemplate = self.templates.top;

      devShell.x86_64-linux = let pkgs = self.legacyPackages.x86_64-linux; in
        pkgs.epnixLib.mkEpnixDevShell "x86_64-linux" {
          devShell.commands = [
            { package = pkgs.mdbook; }
            { package = pkgs.poetry; }
          ];
        };
    });
}
