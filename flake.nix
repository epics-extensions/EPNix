{
  description = "A Nix flake containing EPICS-related modules and packages";

  inputs.bash-lib = {
    url = "github:minijackson/bash-lib";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.devshell.url = "github:numtide/devshell";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";
  inputs.nix-module-doc = {
    url = "git+ssh://git@drf-gitlab.cea.fr/rnicole/nix-module-doc.git";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, bash-lib, devshell, flake-utils, nixpkgs, ... } @ inputs:
    let
      overlay = import ./pkgs;
    in
    with flake-utils.lib;
    ((eachSystem [ "aarch64-linux" "x86_64-linux" ] (system:
      let
        pkgs = import nixpkgs.outPath { inherit system; overlays = [ overlay bash-lib.overlay ]; };
      in
      rec {

        packages = flattenTree (pkgs.recurseIntoAttrs { inherit (pkgs) epnix; }) // {
          manpage = (import ./modules inputs {
            inherit pkgs devshell;
            configuration = { };
            epnixLib = lib;
          }).outputs.manpage;
          doc-options-md = (import ./modules inputs {
            inherit pkgs devshell;
            configuration = { };
            epnixLib = lib;
          }).outputs.doc-options-md;
          mdbook = (import ./modules inputs {
            inherit pkgs devshell;
            configuration = { };
            epnixLib = lib;
          }).outputs.mdbook;
        };

        lib = pkgs.epnixLib;

        # TODO: move that into "lib"
        epnixDistribution = configuration: import ./modules inputs {
          inherit configuration pkgs devshell;
          epnixLib = lib;
        };

        checks = {
          top-simple = pkgs.callPackage ./test/top-simple { };

          base-build = (epnixDistribution {
            epnix = {
              #epics-base.version = "3.16.2";
              support.StreamDevice.enable = true;
              #support.asyn.version = "4-39";
              applications.apps = [
                ./test/top-simple/myExampleApp
                (pkgs.runCommand "ssh-monitorApp"
                  {
                    src = builtins.fetchGit {
                      url = "ssh://git@drf-gitlab.cea.fr/EPICS/ssh-monitorApp.git";
                      rev = "c8836e010ed9bde59bcf275d808bf000b02ff567";
                    };
                  } ''
                  cp -a "$src" "$out"
                '')
              ];
              boot.iocBoots = [ ./test/top-simple/iocBoot/iocmyExample ];
            };
          }).outputs.build;
        };

        devShell = (epnixDistribution {
          devShell.commands = [ { package = pkgs.mdbook; } ];
        }).outputs.devShell;
      })) // {
      inherit overlay;

      templates.top = {
        path = ./templates/top;
        description = "An EPNix TOP project";
      };

      defaultTemplate = self.templates.top;
    });
}
