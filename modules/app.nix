{ lib, ... }:

with lib;

let
  cfg = config.epnix.applications;
in
{
  options.epnix.applications = {
    apps = mkOption {
      default = [];
      type = with types; listOf path;
      description = "Applications to include in this EPICS distribution";
    };
  };
}
