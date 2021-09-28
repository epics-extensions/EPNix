{ config, lib, epnixLib, pkgs, ... }:

with lib;

let
  cfg = config.epnix.base;
  settingsFormat = epnixLib.formats.make { };
in
{
  options.epnix.base = {
    version = mkOption {
      default = "7.0.6";
      type = types.str;
      description = "Version of epics-base to install";
    };

    package = mkOption {
      default = super: super.epics.base.override {
        version = cfg.version;
        local_config_site = cfg.siteConfig;
        local_release = cfg.releaseConfig;
      };
      defaultText = literalExample ''
        super: super.epics.base.override {
          version = cfg.version;
          local_config_site = cfg.siteConfig;
          local_release = cfg.releaseConfig;
        }
      '';
      type = with types; functionTo package;
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
      epics = (super.epics or { }) // {
        base = cfg.package super;
      };
    })
  ];

  config.devShell.devshell.packages = with pkgs; [
    gnumake
    binutils
  ];

  config.devShell.language.c.libraries = with pkgs; [
    readline
  ];

  config.devShell.language.c.includes = with pkgs; [
    readline
  ];

  config.devShell.devshell.startup."epics/base".text = ''
    source "${pkgs.epics.base}/nix-support/setup-hook"
  '';

  config.devShell.commands = mkMerge [
    [
      # Build tools

      {
        help = "Execute make with the relevant variables";
        name = "emake";
        command = ''
          ${pkgs.gnumake}/bin/make \
            "GNU=NO" \
            "CMPLR_CLASS=clang" \
            "CC=clang" \
            "CCC=clang++" \
            "CXX=clang++" \
            "AR=ar" \
            "LD=ld" \
            "RANLIB=ranlib" \
            "ARFLAGS=rc" \
            "$@"
        '';
        category = "EPNix commands";
      }

      # Bootstrapping

      {
        help = "Create a new EPICS App or IOC";
        name = "makeBaseApp.pl";
        command = ''
          ${pkgs.epics.base}/bin/*/makeBaseApp.pl "$@"
        '';
        category = "EPICS bootstrapping commands";
      }

      {
        help = "Create a new EPICS extension directory";
        name = "makeBaseExt.pl";
        command = ''
          ${pkgs.epics.base}/bin/*/makeBaseExt.pl "$@"
        '';
        category = "EPICS bootstrapping commands";
      }

      {
        help = "Create a new EPICS API header";
        name = "makeAPIheader.pl";
        command = ''
          ${pkgs.epics.base}/bin/*/makeAPIheader.pl "$@"
        '';
        category = "EPICS bootstrapping commands";
      }

      # Channel Access

      {
        help = "Obtain a Process Variable value over Channel Access";
        name = "caget";
        command = ''
          ${pkgs.epics.base}/bin/*/caget "$@"
        '';
        category = "EPICS Channel Access commands";
      }

      {
        help = "Get information on a Process Variable over Channel Access";
        name = "cainfo";
        command = ''
          ${pkgs.epics.base}/bin/*/cainfo "$@"
        '';
        category = "EPICS Channel Access commands";
      }

      {
        help = "Monitor a Process Variable over Channel Access";
        name = "camonitor";
        command = ''
          ${pkgs.epics.base}/bin/*/camonitor "$@"
        '';
        category = "EPICS Channel Access commands";
      }

      {
        help = "Set a Process Variable value over Channel Access";
        name = "caput";
        command = ''
          ${pkgs.epics.base}/bin/*/caput "$@"
        '';
        category = "EPICS Channel Access commands";
      }
    ]

    (mkIf (versionAtLeast pkgs.epics.base.version "7.0.0") [

      # pvAccess

      {
        help = "Get a Process Variable value over pvAccess";
        name = "pvget";
        command = ''
          ${pkgs.epics.base}/bin/*/pvget "$@"
        '';
        category = "EPICS pvAccess commands";
      }

      {
        help = "Get information on a Process Variable over pvAccess";
        name = "pvinfo";
        command = ''
          ${pkgs.epics.base}/bin/*/pvinfo "$@"
        '';
        category = "EPICS pvAccess commands";
      }

      {
        help = "List Process Variables over pvAccess";
        name = "pvlist";
        command = ''
          ${pkgs.epics.base}/bin/*/pvlist "$@"
        '';
        category = "EPICS pvAccess commands";
      }

      {
        help = "Monitor a Process Variable over pvAccess";
        name = "pvmonitor";
        command = ''
          ${pkgs.epics.base}/bin/*/pvmonitor "$@"
        '';
        category = "EPICS pvAccess commands";
      }

      {
        help = "Set a Process Variable value over pvAccess";
        name = "pvput";
        command = ''
          ${pkgs.epics.base}/bin/*/pvput "$@"
        '';
        category = "EPICS pvAccess commands";
      }

    ])
  ];
}
