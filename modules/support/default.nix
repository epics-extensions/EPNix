{ config, lib, pkgs, epnixLib, ... }:

with lib;
let
  cfg = config.epnix.support;
in
{
  options.epnix.support = {
    modules = mkOption {
      default = [ ];
      type = types.listOf (epnixLib.types.strOrPackage pkgs);
      description = ''
        Support modules needed for this EPICS distribution.
      '';
    };
  };

  config.devShell.devshell.startup = listToAttrs
    (map
      (module: nameValuePair "epics/${module.pname}" {
        text = ''
          source "${module}/nix-support/setup-hook"
        '';
      })
      cfg.modules);
}
