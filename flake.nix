{
  description = "A Nix flake containing EPICS-related modules and packages";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.devshell.url = "github:numtide/devshell";

  outputs = { self, nixpkgs, flake-utils, devshell }:
    with flake-utils.lib;
    (eachSystem [ "aarch64-linux" "x86_64-linux" ] (system:
      let
        overlay = import ./pkgs;
        pkgs = import nixpkgs.outPath { inherit system; overlays = [ overlay ]; };
      in
      rec {

        packages = flattenTree (pkgs.recurseIntoAttrs { inherit (pkgs) epics; }) // {
          manpage = (import ./modules {
            inherit nixpkgs pkgs devshell;
            configuration = { };
            epnixLib = lib;
          }).outputs.manpage;
          doc-options-md = (import ./modules {
            inherit nixpkgs pkgs devshell;
            configuration = { };
            epnixLib = lib;
          }).outputs.doc-options-md;
        };

        lib = pkgs.epnixLib;

        epnixDistribution = configuration: import ./modules {
          inherit configuration nixpkgs pkgs devshell;
          epnixLib = lib;
        };

        checks = {
          top-simple = pkgs.callPackage ./test/top-simple { };

          base-build = (epnixDistribution {
            epnix = {
              #base.version = "3.16.2";
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

        devShell = (epnixDistribution { }).outputs.devShell;
      })) // {
        templates.ioc = {
          path = ./templates/ioc;
          description = "Build an EPNix distribution IOC";
        };

        defaultTemplate = self.templates.ioc;
      };
}
