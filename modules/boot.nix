{ lib, ... }:

with lib;

let
  cfg = config.epnix.applications;
in
{
  options.epnix.boot = {
    iocBoots = mkOption {
      default = [];
      type = with types; listOf path;
      description = "iocBoot modules to include in this EPICS distribution";
    };
  };
}
