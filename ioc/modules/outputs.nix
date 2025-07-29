{
  config,
  lib,
  pkgs,
  epnix,
  epnixFunEval,
  ...
}:
with lib;
let
  cfg = config.epnix.buildConfig;

  varname = pipe config.epnix.meta.name [
    # Split out all invalid characters
    (builtins.split "[^[:alnum:]]+")
    # Replace invalid character ranges with a "_"
    (concatMapStrings (s: if lib.isList s then "_" else s))
    toUpper
  ];
in
{
  options.epnix = {
    buildConfig = {
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

    generatedOverlay = mkOption {
      description = "A generated overlay which has your package inside `pkgs.epnix.support`.";
      type = with types; functionTo (functionTo attrs);
    };
  };

  config.epnix.buildConfig.src = mkDefault config.epnix.inputs.self;

  config.epnix.generatedOverlay =
    final: prev:
    let
      newEval = final.callPackage epnixFunEval final;
    in
    {
      epnix = prev.epnix.extend (
        _final: prev: {
          support = prev.support.extend (
            _final: _prev: {
              "${config.epnix.meta.name}" = newEval.config.epnix.outputs.build;
            }
          );
        }
      );
    };

  config.epnix.outputs.build = pkgs.mkEpicsPackage (
    {
      pname = "epnix-${config.epnix.meta.name}";
      inherit (config.epnix.meta) version;
      varname = "EPNIX_${varname}";

      buildInputs = config.epnix.support.resolvedModules ++ (cfg.attrs.buildInputs or [ ]);

      src = cfg.src;

      postUnpack = ''
        echo "Copying apps..."
        ${concatMapStringsSep "\n" (app: ''
          cp -rTfv "${app}" "$sourceRoot/${epnix.lib.getName app}"
        '') config.epnix.applications.resolvedApps}

        mkdir -p "$out/iocBoot"

        echo "Copying additional iocBoot directories..."
        ${concatMapStringsSep "\n" (boot: ''
          cp -rTfv "${boot}" "$sourceRoot/iocBoot/${epnix.lib.getName boot}"
        '') config.epnix.boot.resolvedIocBoots}

        # Needed because EPICS tries to create O.* directories in App and
        # iocBoot directories
        chmod -R u+w -- "$sourceRoot"
      ''
      + (cfg.attrs.postUnpack or "");

      postInstall = ''
        if [[ -d iocBoot ]]; then
          cp -rafv iocBoot -t "$out"
        fi

      ''
      + (cfg.attrs.postInstall or "");
    }
    // (removeAttrs cfg.attrs [
      "buildInputs"
      "postInstall"
    ])
  );
}
