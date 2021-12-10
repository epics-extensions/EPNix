{ config, lib, epnixLib, pkgs, ... }:

with lib;

let
  cfg = config.epnix.epics-base;
  settingsFormat = epnixLib.formats.make { };
in
{
  options.epnix.epics-base = {
    version = mkOption {
      default = "7.0.6";
      type = types.str;
      description = "Version of epics-base to install";
    };

    package = mkOption {
      default = super: super.epnix.epics-base.override {
        version = cfg.version;
        local_config_site = cfg.siteConfig;
        local_release = cfg.releaseConfig;
      };
      defaultText = literalExample ''
        super: super.epnix.epics-base.override {
          version = cfg.version;
          local_config_site = cfg.siteConfig;
          local_release = cfg.releaseConfig;
        }
      '';
      type = epnixLib.types.strOrFuncToPackage pkgs;
      description = ''
        Package to use for epics-base.

        Defaults to the official distribution with the given version and given
        RELEASE and CONFIG_SITE.
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

  config.nixpkgs.overlays = [
    (self: super: {
      epnix = (super.epnix or { }) // {
        epics-base = cfg.package super;
      };
    })
  ];

  config.devShell.devshell.packages = with pkgs; [
    gnumake
    binutils
  ];

  config.devShell.language.c = {
    compiler = pkgs.gcc;
    libraries = with pkgs; [
      readline
    ];

    includes = with pkgs; [
      readline
    ];
  };

  config.devShell.env = [
    # `CMD_...` are flags that we can set from the "command-line"
    # We set these as environment variables, which should work since they are
    # explicitely not instanciated in the Makefile hell.
    { name = "CMD_CFLAGS"; value = "-fdiagnostics-color=always"; }
    { name = "CMD_CXXFLAGS"; value = "-fdiagnostics-color=always"; }
  ];

  config.devShell.devshell.startup."epnix/epics-base".text = ''
    source "${pkgs.epnix.epics-base}/nix-support/setup-hook"
  '';

  config.devShell.commands = mkMerge [
    [
      # Bootstrapping

      {
        help = "Create a new EPICS App or IOC";
        name = "makeBaseApp.pl";
        command = ''
          ${pkgs.epnix.epics-base}/bin/*/makeBaseApp.pl "$@"
        '';
        category = "EPICS bootstrapping commands";
      }

      {
        help = "Create a new EPICS extension directory";
        name = "makeBaseExt.pl";
        command = ''
          ${pkgs.epnix.epics-base}/bin/*/makeBaseExt.pl "$@"
        '';
        category = "EPICS bootstrapping commands";
      }

      {
        help = "Create a new EPICS API header";
        name = "makeAPIheader.pl";
        command = ''
          ${pkgs.epnix.epics-base}/bin/*/makeAPIheader.pl "$@"
        '';
        category = "EPICS bootstrapping commands";
      }

      # Channel Access

      {
        help = "Obtain a Process Variable value over Channel Access";
        name = "caget";
        command = ''
          ${pkgs.epnix.epics-base}/bin/*/caget "$@"
        '';
        category = "EPICS Channel Access commands";
      }

      {
        help = "Get information on a Process Variable over Channel Access";
        name = "cainfo";
        command = ''
          ${pkgs.epnix.epics-base}/bin/*/cainfo "$@"
        '';
        category = "EPICS Channel Access commands";
      }

      {
        help = "Monitor a Process Variable over Channel Access";
        name = "camonitor";
        command = ''
          ${pkgs.epnix.epics-base}/bin/*/camonitor "$@"
        '';
        category = "EPICS Channel Access commands";
      }

      {
        help = "Set a Process Variable value over Channel Access";
        name = "caput";
        command = ''
          ${pkgs.epnix.epics-base}/bin/*/caput "$@"
        '';
        category = "EPICS Channel Access commands";
      }
    ]

    (mkIf (versionAtLeast pkgs.epnix.epics-base.version "7.0.0") [

      # pvAccess

      {
        help = "Get a Process Variable value over pvAccess";
        name = "pvget";
        command = ''
          ${pkgs.epnix.epics-base}/bin/*/pvget "$@"
        '';
        category = "EPICS pvAccess commands";
      }

      {
        help = "Get information on a Process Variable over pvAccess";
        name = "pvinfo";
        command = ''
          ${pkgs.epnix.epics-base}/bin/*/pvinfo "$@"
        '';
        category = "EPICS pvAccess commands";
      }

      {
        help = "List Process Variables over pvAccess";
        name = "pvlist";
        command = ''
          ${pkgs.epnix.epics-base}/bin/*/pvlist "$@"
        '';
        category = "EPICS pvAccess commands";
      }

      {
        help = "Monitor a Process Variable over pvAccess";
        name = "pvmonitor";
        command = ''
          ${pkgs.epnix.epics-base}/bin/*/pvmonitor "$@"
        '';
        category = "EPICS pvAccess commands";
      }

      {
        help = "Set a Process Variable value over pvAccess";
        name = "pvput";
        command = ''
          ${pkgs.epnix.epics-base}/bin/*/pvput "$@"
        '';
        category = "EPICS pvAccess commands";
      }

    ])
  ];
}
