{ config, lib, pkgs, epnixPkgs, epnixLib, ... }:

with lib;

let
  cfg = config.epnix.base;
  settingsFormat = epnixLib.formats.make { };
in
{
  options.epnix.base = {
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

    releaseConfig = mkOption {
      default = { };
      description = "Configuration installed as RELEASE";
      type = types.submodule {
        freeformType = settingsFormat.type;
        options = { };
      };
    };

    siteConfig = mkOption {
      default = { };
      description = "Configuration installed as CONFIG_SITE";
      type = types.submodule {
        freeformType = settingsFormat.type;
        options = { };
      };
    };
  };

  # TODO: this is hacky
  config.epnix.base.releaseConfig = {
    "EPICS_BASE:" = "$(out)/epics-base";
    "SUPPORT:" = "$(out)/support";
  };

  config.epnix.buildConfig = {
    nativeBuildInputs = with pkgs; [ perl ];
    buildInputs = with pkgs; [ readline ];
  };

  config.epnix.source.dirs."epics-base" = {
    src = cfg.package;
    patches = [ ../pkgs/epics/base/use-env-substitution-in-checkRelease.patch ];
    copyFiles."configure/RELEASE.local".src = settingsFormat.generate "epics-base-RELEASE.local" cfg.releaseConfig;
    copyFiles."configure/CONFIG_SITE.local".src = settingsFormat.generate "epics-base-CONFIG_SITE.local" cfg.siteConfig;
  };
}
