{ basePkgs, config, lib, pkgs, epnixLib, ... }:

with lib;

let
  cfg = config.epnix.support.asyn;
  settingsFormat = epnixLib.formats.make { };
in
{
  options.epnix.support.asyn = {
    enable = mkEnableOption "Whether to install asyn in this EPICS distribution";

    version = mkOption {
      default = "4-42";
      type = types.str;
      description = "Version of asyn to install";
    };

    package = mkOption {
      default = basePkgs.epics.support.asyn.override {
        version = cfg.version;
        local_config_site = cfg.siteConfig;
        local_release = cfg.releaseConfig;
      };
      type = types.package;
      description = ''
        Package to use for asyn.

        Defaults to the official distribution with the given version and
        configuration.
      '';
    };

    # TODO:
    withCalc = mkEnableOption "Enable Calc support";
    withIpac = mkEnableOption "Enable IPAC support";
    withSeq = mkEnableOption "Enable Seq support";
    withSscan = mkEnableOption "Enable SSCAN support";

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
    # TODO: make a function?
    epics = (super.epics or {}) // {
      support = (super.epics.support or {}) // {
        asyn = cfg.package;
      };
    };
  }) ];

  config.epnix.support.modules = [
    pkgs.epics.support.asyn
  ];
}
