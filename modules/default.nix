{ configuration, pkgs, epnixPkgs, epnixLib, }:

let
  lib = pkgs.lib;
  eval = lib.evalModules {
    modules = [
      ({ config, lib, ... }: with lib; {
        options = {
          nixpkgs.overlays = mkOption {
            default = [];
            type = types.listOf types.unspecified;
            description = "Nixpkgs overlays to override the default packages used";
          };

          epnix.build = mkOption {
            internal = true;
            default = { };
            type = types.attrs;
          };
        };

        config._module.args = let
          finalPkgs = pkgs.appendOverlays config.nixpkgs.overlays;
        in {
          inherit epnixPkgs epnixLib;
          pkgs = finalPkgs;
        };
      })

      configuration

      ./assertions.nix
      ./base.nix
      ./build.nix
      ./source.nix

      ./support/asyn.nix
      ./support/synApps.nix
    ];
  };

  # From Robotnix
  # From nixpkgs/nixos/modules/system/activation/top-level.nix
  failedAssertions = map (x: x.message) (lib.filter (x: !x.assertion) eval.config.assertions);

  config =
    if failedAssertions != [ ]
    then throw "\nFailed assertions:\n${lib.concatStringsSep "\n" (map (x: "- ${x}") failedAssertions)}"
    else lib.showWarnings eval.config.warnings eval.config;
in
{
  inherit (eval) pkgs options;
  inherit config;

  inherit (config.epnix.build) build source;
}
