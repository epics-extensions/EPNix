{ config, lib, pkgs, epnixPkgs, epnixLib, ... }:

with lib;

let
  cfg = config.epnix.support.asyn;
  settingsFormat = epnixLib.formats.make { };
in
{
  options.epnix.support.asyn = {
    enable = mkEnableOption "Whether to install asyn in the EPICS distribution support source tree";

    version = mkOption {
      default = "4-42";
      type = types.str;
      description = "Version of asyn to install";
    };

    package = mkOption {
      default = epnixPkgs."epics/support/asyn".override { rev = "R${cfg.version}"; };
      type = types.package;
      description = "Package to use for asyn. Defaults to the official distribution with the given version";
    };

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

  config.epnix.support.asyn = {
    releaseConfig = {
      # TODO: this is hacky
      "EPICS_BASE:" = "$(out)/epics-base";
      "SUPPORT:" = "$(out)/support";

      CALC = if cfg.withCalc then "$(wildcard $(out)/support/synApps/support/calc-*/)" else null;
      IPAC = if cfg.withIpac then "$(wildcard $(out)/support/synApps/support/ipac-*/)" else null;
      SNCSEQ = if cfg.withSeq then "$(wildcard $(out)/support/synApps/support/seq-*/)" else null;
      SSCAN = if cfg.withSscan then "$(wildcard $(out)/support/synApps/support/sscan-*/)" else null;
    };

    siteConfig = {
      TIRPC = "YES";
    };
  };

  config.epnix.buildConfig = {
    nativeBuildInputs = with pkgs; [ pkg-config rpcsvc-proto ];
    buildInputs = with pkgs; [ libtirpc ];
  };

  config.epnix.source.dirs."support/asyn" = mkIf cfg.enable {
    src = cfg.package;
    patches = [ ../../pkgs/epics/support/asyn/use-pkg-config.patch ];
    copyFiles = {
      "configure/RELEASE.local".src = settingsFormat.generate "asyn-RELEASE.local" cfg.releaseConfig;
      "configure/CONFIG_SITE.local".src = settingsFormat.generate "asyn-CONFIG_SITE.local" cfg.siteConfig;
    };
    build.dependsOn = mkIf (cfg.withIpac || cfg.withSeq || cfg.withCalc || cfg.withSscan) [ "support/synApps" ];
  };
}
