{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.epnix.buildConfig;
in
{
  options.epnix.buildConfig = {
    flavor = mkOption {
      description = "Name of the flavor of this EPICS distribution";
      type = types.str;
      default = "custom";
    };

    version = mkOption {
      description = "Version of this EPICS distribution";
      type = types.str;
      default = "0.0.1";
    };
  };

  config.epnix.build.topSource = pkgs.runCommand "epics-distribution-${cfg.flavor}-top-source" { } ''
    mkdir -p "$out"

    cp -rfv --no-preserve=mode "${pkgs.epics.base}/templates/makeBaseApp/top/configure" "$out"
    cp -rfv "${pkgs.epics.base}/templates/makeBaseApp/top/Makefile" "$out"

    ${concatMapStringsSep "\n" (app: ''
      cp -rfv "${app}" "$out/${baseNameOf app}"
    '') config.epnix.applications.apps}

    mkdir -p "$out/iocBoot"
    cp -rfv "${pkgs.epics.base}/templates/makeBaseApp/top/iocBoot/Makefile" "$out/iocBoot"

    ${concatMapStringsSep "\n" (boot: ''
      cp -rfv "${boot}" "$out/iocBoot/${baseNameOf boot}"
    '') config.epnix.boot.iocBoots}
  '';

  config.epnix.build.build =
    pkgs.mkEpicsPackage {
      pname = "epics-distribution-${cfg.flavor}";
      version = cfg.version;
      varname = "EPICS_DISTRIBUTION_${cfg.flavor}";

      buildInputs = config.epnix.support.modules;

      src = config.epnix.build.topSource;

      postInstall = ''
        cp -rafv iocBoot "$out"
      '';
    };
}
