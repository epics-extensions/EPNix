{ config, lib, pkgs, epnixPkgs, epnixLib, ... }:

with lib;

let
  cfg = config.epnix.support.synApps;
  settingsFormat = epnixLib.formats.make { };
in
{
  options.epnix.support.synApps = {
    enable = mkEnableOption "Whether to install synApps in the EPICS distribution support source tree";

    version = mkOption {
      default = "6_1";
      type = types.str;
      description = "Version of asyn to install";
    };

    package = mkOption {
      default = epnixPkgs."epics/support/synApps".override { rev = cfg.version; };
      type = types.package;
      description = "Package to use for synApps. Defaults to the official distribution with the given version";
    };
  };

  config.epnix.source.dirs."support/synApps" = mkIf cfg.enable {
    src = cfg.package;
  };
}
