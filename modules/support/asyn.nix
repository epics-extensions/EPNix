{ config, lib, pkgs, epnixLib, ... }:

with lib;

let
  cfg = config.epnix.support.asyn;
  settingsFormat = epnixLib.formats.make { };
in
{
  options.epnix.support.asyn = {
    enable = mkEnableOption "asyn in this EPICS distribution";

    package = mkOption {
      default = super: super.epnix.support.asyn.override {
        local_config_site = cfg.siteConfig;
        local_release = cfg.releaseConfig;
      };
      defaultText = literalExample ''
        super: super.epnix.support.asyn.override {
          local_config_site = cfg.siteConfig;
          local_release = cfg.releaseConfig;
        }
      '';
      type = epnixLib.types.strOrFuncToPackage pkgs;
      description = ''
        Package to use for asyn.

        Defaults to the official distribution with the given configuration.
      '';
    };

    # TODO:
    withCalc = mkEnableOption "Calc support for asyn";
    withIpac = mkEnableOption "IPAC support for asyn";
    withSeq = mkEnableOption "Seq support for asyn";
    withSscan = mkEnableOption "SSCAN support for asyn";

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

  config = mkIf cfg.enable {
      nixpkgs.overlays = [ (self: super: {
      # TODO: make a function?
      epnix = (super.epnix or {}) // {
        support = (super.epnix.support or {}) // {
          asyn = cfg.package super;
        };
      };
    }) ];

    epnix.support.modules = [
      pkgs.epnix.support.asyn
    ];
  };
}
