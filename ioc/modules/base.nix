{
  config,
  lib,
  epnix,
  pkgs,
  ...
}:
with lib; let
  cfg = config.epnix.epics-base;
in {
  options.epnix.epics-base = {
    releaseBranch = mkOption {
      default = "7";
      type = types.enum ["7" "3"];
      description = "The release branch of epics-base to install";
    };

    package = mkOption {
      default = pkgs.epnix."epics-base${cfg.releaseBranch}";
      defaultText = literalExpression ''
        pkgs.epnix."epics-base''${releaseBranch}"
      '';
      type = types.package;
      description = ''
        Package to use for epics-base.

        Defaults to the official distribution from the given release branch and
        with the given RELEASE and CONFIG_SITE.
      '';
    };
  };

  config.epnix.devShell = {
    environment.variables = {
      # `CMD_...` are flags that we can set from the "command-line"
      # We set these as environment variables, which should work since they are
      # explicitely not instanciated in the Makefile hell.
      CMD_CFLAGS = "-fdiagnostics-color=always";
      CMD_CXXFLAGS = "-fdiagnostics-color=always";
      EPICS_MBA_DEF_APP_TYPE = null;
      EPICS_MBA_TEMPLATE_TOP = null;
      EPICS_MBA_BASE = null;
    };

    packages = [
      {
        inherit (cfg) package;
        commands = mkMerge [
          {
            # Bootstrapping

            "makeBaseApp.pl" = {
              category = "epics bootstrapping commands";
              description = "Create a new EPICS App or IOC";
            };

            "makeBaseExt.pl" = {
              category = "epics bootstrapping commands";
              description = "Create a new EPICS extension directory";
            };

            # Channel Access

            "caget" = {
              category = "epics channel access commands";
              description = "Obtain a Process Variable value over Channel Access";
            };

            "cainfo" = {
              category = "epics channel access commands";
              description = "Get information on a Process Variable over Channel Access";
            };

            "camonitor" = {
              category = "epics channel access commands";
              description = "Monitor a Process Variable over Channel Access";
            };

            "caput" = {
              category = "epics channel access commands";
              description = "Set a Process Variable value over Channel Access";
            };
          }

          (mkIf (versionAtLeast pkgs.epnix.epics-base.version "7.0.0") {
            # pvAccess

            "pvget" = {
              category = "epics pvAccess commands";
              description = "Get a Process Variable value over pvAccess";
            };

            "pvinfo" = {
              category = "epics pvAccess commands";
              description = "Get information on a Process Variable over pvAccess";
            };

            "pvlist" = {
              category = "epics pvAccess commands";
              description = "List Process Variables over pvAccess";
            };

            "pvmonitor" = {
              category = "epics pvAccess commands";
              description = "Monitor a Process Variable over pvAccess";
            };

            "pvput" = {
              category = "epics pvAccess commands";
              description = "Set a Process Variable value over pvAccess";
            };
          })
        ];
      }
    ];
  };

  config.nixpkgs.overlays = [
    (_final: prev: {
      epnix =
        prev.epnix
        // {
          epics-base = cfg.package;
        };
    })
  ];
}
