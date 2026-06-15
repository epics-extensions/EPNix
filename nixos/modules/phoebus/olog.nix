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

          "spring.ldap.embedded.base-dn" = lib.mkOption {
            description = ''
              The base DN for the embedded LDAP.

              :::{note}
              Setting this value to a non-empty string
              will start the embedded LDAP,
              no matter the value of {nix:option}`"embedded_ldap.enabled"`,
              which may lead to port conflicts
              if you deploy multiple Phoebus services.
              :::
            '';
            type = lib.types.str;
            default = if cfg.settings."embedded_ldap.enabled" == "true" then "dc=olog,dc=local" else "";
            defaultText = lib.literalExpression ''if cfg.settings."embedded_ldap.enabled" == "true" then "dc=olog,dc=local" else ""'';
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
      description = "Phoebus Olog Server";

      wantedBy = [ "multi-user.target" ];
      after = [
        "elasticsearch.service"
        "ferretdb.service"
      ];

      serviceConfig = {
        ExecStart = "${lib.getExe pkgs.epnix.phoebus-olog} --spring.config.location=file://${configFile}";
        DynamicUser = true;

        # Security options:
        # ---

        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];
        # Service may not create new namespaces
        RestrictNamespaces = true;

        # Service does not have access to other users
        PrivateUsers = true;
        # Service has no access to hardware devices
        PrivateDevices = true;

        # Service cannot write to the hardware clock or system clock
        ProtectClock = true;
        # Service cannot modify the control group file system
        ProtectControlGroups = true;
        # Service has no access to home directories
        ProtectHome = true;
        # Service cannot change system host/domainname
        ProtectHostname = true;
        # Service cannot read from or write to the kernel log ring buffer
        ProtectKernelLogs = true;
        # Service cannot load or read kernel modules
        ProtectKernelModules = true;
        # Service cannot alter kernel tunables (/proc/sys, …)
        ProtectKernelTunables = true;
        # Service has restricted access to process tree (/proc hidepid=)
        ProtectProc = "invisible";

        # Service may not acquire new capabilities
        CapabilityBoundingSet = "";
        # Service cannot change ABI personality
        LockPersonality = true;
        # Service has no access to non-process /proc files (/proc subset=)
        ProcSubset = "pid";
        # Service may execute system calls only with native ABI
        SystemCallArchitectures = "native";
        # Access write directories
        UMask = "0077";
        # Service may create writable executable memory mappings
        # This option isn't set due to the JVM marking some memory pages as executable
        #MemoryDenyWriteExecute = true;

        # Service can only use a reasonable set of system calls,
        # used by common system services
        SystemCallFilter = [ "@system-service" ];
        # Disallowed system calls return EPERM instead of terminating the service
        SystemCallErrorNumber = "EPERM";
      };
    };
    services.ferretdb = {
      enable = true;
      settings.FERRETDB_TELEMETRY = "disable";
    };
  };

  meta.maintainers = with epnixLib.maintainers; [ minijackson ];
}
