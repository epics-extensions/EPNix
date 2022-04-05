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

    src = mkOption {
      description = ''
        The source code for the top.

        Defaults to the directory containing the `flake.nix` file.
      '';
      type = types.path;
    };
  };

  config.epnix.buildConfig.src = mkDefault config.epnix.inputs.self;

  config.epnix.outputs.build =
    pkgs.mkEpicsPackage ({
      pname = "epics-distribution-${cfg.flavor}";
      version = cfg.version;
      varname = "EPICS_DISTRIBUTION_${cfg.flavor}";

      buildInputs = config.epnix.support.resolvedModules ++ (cfg.attrs.buildInputs or [ ]);

      src = cfg.src;

      postUnpack = ''
        echo "Copying apps..."
        ${concatMapStringsSep "\n" (app: ''
          cp -rfv "${app}" "$sourceRoot/${epnixLib.getName app}"
        '') config.epnix.applications.resolvedApps}

        mkdir -p "$out/iocBoot"

        echo "Copying additional iocBoot directories..."
        ${concatMapStringsSep "\n" (boot: ''
          cp -rfv "${boot}" "$sourceRoot/iocBoot/${epnixLib.getName boot}"
        '') config.epnix.boot.resolvedIocBoots}

        # Needed because EPICS tries to create O.* directories in App and
        # iocBoot directories
        chmod -R u+w -- "$sourceRoot"
      '' + (cfg.attrs.postUnpack or "");

      postInstall = ''
        cp -rafv iocBoot "$out"

      '' + (cfg.attrs.postInstall or "");
    } // (removeAttrs cfg.attrs [ "buildInputs" "postInstall" ]));
}
