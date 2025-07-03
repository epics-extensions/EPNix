{
  config,
  epnixLib,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.phoebus-olog;
  settingsFormat = pkgs.formats.javaProperties { };
  configFile = settingsFormat.generate "phoebus-olog.properties" cfg.settings;
in
{
  options.services.phoebus-olog = {
    enable = lib.mkEnableOption "the Phoebus Olog service";

    settings = lib.mkOption {
      description = ''
        Configuration for the Phoebus Olog service.

        These options will be put into a `.properties` file.

        Note that options containing a "." must be quoted.

        See here for supported options:
        <https://github.com/Olog/phoebus-olog/blob/v${pkgs.epnix.phoebus-olog.version}/src/main/resources/application.properties>
      '';
      default = { };
      type = lib.types.submodule {
        freeformType = settingsFormat.type;
        options = {
          "server.port" = lib.mkOption {
            type = lib.types.port;
            default = 8181;
            # TODO: Weirdness of the javaProperties format?
            # It says it supports integers and booleans, but during the build
            # only accepts strings?
            apply = toString;
            description = "The server port for the REST service.";
          };

          "server.http.enable" = lib.mkOption {
            type = lib.types.bool;
            default = false;
            apply = lib.boolToString;
            description = "Enable unsecure HTTP.";
          };

          "demo_auth.enabled" = lib.mkOption {
            type = lib.types.bool;
            default = false;
            apply = lib.boolToString;
            description = ''
              Enable the demo authentication.

              Phoebus will provide two users:

              - `admin:adminPass`
              - `user:userPass`
            '';
          };

          "ad.enabled" = lib.mkOption {
            type = lib.types.bool;
            default = false;
            apply = lib.boolToString;
            description = ''
              Enable authenticating to an external Active Directory server.
            '';
          };

          "ldap.enabled" = lib.mkOption {
            type = lib.types.bool;
            default = false;
            apply = lib.boolToString;
            description = ''
              Enable authenticating to an external LDAP server.
            '';
          };

          "embedded_ldap.enabled" = lib.mkOption {
            type = lib.types.bool;
            default = false;
            apply = lib.boolToString;
            description = ''
              Enable the embedded LDAP authentication.
            '';
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion =
          with cfg;
          (settings."ad.enabled" == "true")
          || settings."ldap.enabled" == "true"
          || settings."embedded_ldap.enabled" == "true"
          || settings."demo_auth.enabled" == "true";
        message = "One type of authentication for Phoebus Olog must be provided";
      }
    ];

    systemd.services.phoebus-olog = {
      description = "Phoebus Alarm Server";

      wantedBy = [ "multi-user.target" ];
      after = [
        "elasticsearch.service"
        "ferretdb.service"
      ];

      serviceConfig = {
        ExecStart = "${lib.getExe pkgs.epnix.phoebus-olog} --spring.config.location=file://${configFile}";
        DynamicUser = true;
        # TODO: systemd hardening. Currently level 8.2 EXPOSED
      };
    };
    services.ferretdb = {
      enable = true;
      settings.FERRETDB_TELEMETRY = "disable";
    };
  };

  meta.maintainers = with epnixLib.maintainers; [ minijackson ];
}
