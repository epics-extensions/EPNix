inputs:

{ configuration, pkgs, devshell, epnixLib, }:

let
  lib = pkgs.lib;

  docParams = {
    outputAttrPath = [ "epnix" "outputs" ];
    optionsAttrPath = [ "epnix" "doc" ];
  };

  eval = lib.evalModules {
    modules = [
      ({
        config._module.args =
          let
            finalPkgs = pkgs.appendOverlays config.nixpkgs.overlays;
          in
          {
            inherit devshell;
            pkgs = finalPkgs;
          };
      })

      configuration
      (inputs.nix-module-doc.lib.modules.doc-options-md docParams)
      (inputs.nix-module-doc.lib.modules.manpage docParams)
      (inputs.nix-module-doc.lib.modules.mdbook docParams)
    ] ++ (import ./module-list.nix);

    specialArgs = { inherit epnixLib; };
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
