{ lib, ... }:

with lib;
let
  cfg = config.epnix.support;
in
{
  options.epnix.support = {
    modules = mkOption {
      default = [];
      type = with types; listOf package;
      description = ''
        Support modules needed for this EPICS distribution.
      '';
    };
  };
}
