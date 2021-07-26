{ basePkgs, config, lib, epnixLib, ... }:

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
      default = basePkgs.epics.base.override {
        version = cfg.version;
        local_config_site = cfg.siteConfig;
        local_release = cfg.releaseConfig;
      };
      type = types.package;
      description = ''
        Package to use for epics-base.

        Defaults to the official distribution with the given version and given
        RELEASE and CONFIG_SITE.
      '';
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

  config.nixpkgs.overlays = [ (self: super: {
    epics = (super.epics or {}) // {
      base = cfg.package;
    };
  }) ];
}
