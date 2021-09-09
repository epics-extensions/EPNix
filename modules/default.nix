{ configuration, nixpkgs, pkgs, devshell, epnixLib, }:

let
  lib = pkgs.lib;
  eval = lib.evalModules {
    modules = [
      ({
        config._module.args =
          let
            finalPkgs = pkgs.appendOverlays config.nixpkgs.overlays;
          in
          {
            inherit epnixLib devshell;
            pkgs = finalPkgs;
          };
      })

      configuration
    ] ++ (import ./module-list.nix);
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

  inherit (config.epnix) outputs;
}
