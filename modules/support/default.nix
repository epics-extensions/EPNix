{ config, lib, ... }:

with lib;
let
  cfg = config.epnix.support;
in
{
  options.epnix.support = {
    modules = mkOption {
      default = [ ];
      type = with types; listOf package;
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
