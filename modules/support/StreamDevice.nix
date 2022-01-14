{ config, lib, pkgs, epnixLib, ... }:

with lib;

let
  cfg = config.epnix.support.StreamDevice;
  settingsFormat = epnixLib.formats.make { };
in
{
  options.epnix.support.StreamDevice = {
    enable = mkEnableOption "StreamDevice in this EPICS distribution";

    package = mkOption {
      default = super: super.epnix.support.StreamDevice.override {
        local_config_site = cfg.siteConfig;
        local_release = cfg.releaseConfig;
      };
      defaultText = literalExpression ''
        super: super.epnix.support.StreamDevice.override {
          local_config_site = cfg.siteConfig;
          local_release = cfg.releaseConfig;
        }
      '';
      type = epnixLib.types.strOrFuncToPackage pkgs;
      description = ''
        Package to use for StreamDevice.

        Defaults to the official distribution with the given configuration.
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

  config = mkIf cfg.enable {
      nixpkgs.overlays = [ (self: super: {
      # TODO: make a function?
      epnix = (super.epnix or {}) // {
        support = (super.epnix.support or {}) // {
          StreamDevice = cfg.package super;
        };
      };
    }) ];

    epnix.support = {
      # TODO: calc
      asyn.enable = true;

      modules = [
        pkgs.epnix.support.StreamDevice
      ];
    };
  };
}
