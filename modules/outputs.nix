{ config, lib, pkgs, epnixLib, ... }:

with lib;
let
  cfg = config.epnix.buildConfig;
in
{
  options.epnix.buildConfig = {
    # TODO: move into meta
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

    cp -rfv --no-preserve=mode "${pkgs.epnix.epics-base}/templates/makeBaseApp/top/configure" "$out"
    ${# Include CONFIG_SITE.local and RELEASE.local in the top "template"
      # Fixed by commit aa6e976f92d144b5143cf267d8b2781d3ec8b62b
      optionalString (versionOlder pkgs.epnix.epics-base.version "3.15.5") ''
        cat >> "$out/configure/CONFIG_SITE" <<'EOF'
        -include $(TOP)/../CONFIG_SITE.local
        -include $(TOP)/configure/CONFIG_SITE.local
        EOF

        cat >> "$out/configure/RELEASE" <<'EOF'
        -include $(TOP)/../RELEASE.local
        -include $(TOP)/configure/RELEASE.local
        EOF
      ''}
    cp -rfv "${pkgs.epnix.epics-base}/templates/makeBaseApp/top/Makefile" "$out"

    ${concatMapStringsSep "\n" (app: ''
      cp -rfv "${app}" "$out/${epnixLib.getName app}"
    '') config.epnix.applications.resolvedApps}

    mkdir -p "$out/iocBoot"
    cp -rfv "${pkgs.epnix.epics-base}/templates/makeBaseApp/top/iocBoot/Makefile" "$out/iocBoot"

    ${concatMapStringsSep "\n" (boot: ''
      cp -rfv "${boot}" "$out/iocBoot/${epnixLib.getName boot}"
    '') config.epnix.boot.resolvedIocBoots}
  '';

  config.epnix.outputs.build =
    pkgs.mkEpicsPackage ({
      pname = "epics-distribution-${cfg.flavor}";
      version = cfg.version;
      varname = "EPICS_DISTRIBUTION_${cfg.flavor}";

      buildInputs = config.epnix.support.resolvedModules ++ (cfg.attrs.buildInputs or [ ]);

      src = config.epnix.outputs.topSource;

      postInstall = ''
        cp -rafv iocBoot "$out"

      '' + (cfg.attrs.postInstall or "");
    } // (removeAttrs cfg.attrs [ "buildInputs" "postInstall" ]));
}
