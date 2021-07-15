{ config, lib, epnixPkgs, epnixLib, ... }:

with lib;

let
  cfg = config.epnix.base;
  settingsFormat = epnixLib.formats.make {};
in
{
  options.epnix.base = {
    enable = mkOption {
      default = true;
      type = types.bool;
      description = "Whether to install epics-base in the EPICS distribution source tree";
    };

    version = mkOption {
      default = "7.0.6";
      type = types.str;
      description = "Version of epics-base to install";
    };

    package = mkOption {
      default = epnixPkgs."epics/base".override { rev = "R${cfg.version}"; };
      type = types.package;
      description = "Package to use for epics-base. Defaults to the official distribution with the given version";
    };

    config = mkOption {
      default = { };
      description = "Configuration installed as CONFIG_SITE";
      type = types.submodule {
        freeformType = settingsFormat.type;
        options = {

        };
      };
    };
  };

  config.epnix.source.dirs."epics-base" = {
    src = cfg.package;
    copyFiles."configure/CONFIG_SITE.local".src = settingsFormat.generate "epics-base-CONFIG_SITE.local" cfg.config;
  };
}
