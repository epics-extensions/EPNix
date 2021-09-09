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

    attrs = mkOption {
      description = "Extra attributes to pass to the derivation";
      type = types.attrs;
      default = { };
    };
  };

  config.epnix.outputs.topSource = pkgs.runCommand "epics-distribution-${cfg.flavor}-top-source" { } ''
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

  config.epnix.outputs.build =
    pkgs.mkEpicsPackage ({
      pname = "epics-distribution-${cfg.flavor}";
      version = cfg.version;
      varname = "EPICS_DISTRIBUTION_${cfg.flavor}";

      buildInputs = config.epnix.support.modules ++ (cfg.attrs.buildInputs or [ ]);

      src = config.epnix.outputs.topSource;

      postInstall = ''
        cp -rafv iocBoot "$out"

      '' + (cfg.attrs.postInstall or "");
    } // (removeAttrs cfg.attrs [ "buildInputs" "postInstall" ]));
}
