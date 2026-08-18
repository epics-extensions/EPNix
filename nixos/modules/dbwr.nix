{
  config,
  epnixLib,
  lib,
  options,
  pkgs,
  ...
}:
let
  cfg = config.services.dbwr;
  tomcatPkgVersion = config.services.tomcat.package.version;
  tomcatPkgOpt = options.services.tomcat.package;
in
{
  options.services.dbwr = {
    enable = lib.mkEnableOption "DBWR, the display builder web runtime";

    package = lib.mkPackageOption pkgs "DBWR" {
      default = [
        "epnix"
        "dbwr"
      ];
    };

    openFirewall = lib.mkOption {
      description = ''
        Open the firewall for the DBWR service.

        :::{warning}
        This opens the firewall on all network interfaces.
        :::
      '';
      type = lib.types.bool;
      default = false;
    };

    settings = lib.mkOption {
      description = ''
        Configuration for DBWR.

        These options will be passed as environment variables.
      '';
      default = { };
      type = lib.types.submodule {
        freeformType =
          with lib.types;
          attrsOf (oneOf [
            str
            path
          ]);
        options = {
          # Options that should be in PVWS
          EPICS_CA_ADDR_LIST = lib.mkOption {
            visible = false;
            default = null;
          };
          EPICS_CA_AUTO_ADDR_LIST = lib.mkOption {
            visible = false;
            default = null;
          };
          PV_DEFAULT_TYPE = lib.mkOption {
            visible = false;
            default = null;
          };
          PV_WRITE_SUPPORT = lib.mkOption {
            visible = false;
            default = null;
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions =
      (map
        (setting: {
          assertion = cfg.settings.${setting} == null;
          message = "The option `services.dbwr.settings.${setting}` has been renamed to `services.pvws.settings.${setting}`.";
        })
        [
          "EPICS_CA_ADDR_LIST"
          "EPICS_CA_AUTO_ADDR_LIST"
          "PV_DEFAULT_TYPE"
          "PV_WRITE_SUPPORT"
        ]
      )
      ++ [
        {
          assertion = (lib.versions.major tomcatPkgVersion) == "9";
          message = ''
            DBWR requires Tomcat 9, but Tomcat was set to version '${tomcatPkgVersion}' in ${lib.showFiles tomcatPkgOpt.files}.
            ${lib.optionalString config.services.archiver-appliance.enable ''
              Note: enabling both DBWR and Archiver Appliance in the same NixOS configuration is not possible,
              see the 26.05 release notes:

                  https://epics-extensions.github.io/EPNix/${epnixLib.versions.current}/release-notes/2605.html
            ''}'';
        }
      ];

    services.dbwr.settings.CATALINA_OUT_CMD = "cat";

    services.pvws.enable = lib.mkDefault true;

    services.tomcat = {
      enable = true;
      # See comment in archiver-appliance.nix
      purifyOnStart = true;
      webapps = [ cfg.package ];
    };

    systemd.services.tomcat.environment = lib.filterAttrs (_: val: val != null) cfg.settings;

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ config.services.tomcat.port ];
  };

  meta.maintainers = with epnixLib.maintainers; [ minijackson ];
}
