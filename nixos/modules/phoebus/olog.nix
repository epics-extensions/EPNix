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

        :::{note}
        Contrary to upstream,
        the Phoebus Olog service listens to HTTP connections,
        not HTTPS.
        :::
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
            description = "The HTTP server port for the REST service.";
          };

          "authenticationProviders" = lib.mkOption {
            type =
              with lib.types;
              listOf (enum [
                "inMemory"
                "embeddedLdap"
                "ldap"
                "activeDirectory"
              ]);
            apply = lib.concatStringsSep ",";
            description = ''
              User authentication providers.

              Multiple authentication providers can be provided,
              which will be tried in the given order.

              For the `inMemory` authentication provider,
              two users are provided:

              - `admin:adminPass`
              - `user:userPass`

              For more information, see [upstream's authentication documentation].

                [upstream's authentication documentation]: https://olog.readthedocs.io/en/latest/sysadmin/guides/configuring/authentication.html
            '';
          };
        };
        config = {
          # Disable SSL
          "security.require-ssl" = lib.mkDefault false;
          "server.ssl.enabled" = lib.mkDefault false;
          # Unset the loading of private keys from the Git repository
          "server.ssl.key-store-type" = lib.mkDefault "";
          "server.ssl.key-store" = lib.mkDefault "";
          "server.ssl.key-store-password" = lib.mkDefault "";
          "server.ssl.key-alias" = lib.mkDefault "";
          # We've already switched to HTTP, no need for a second one
          "server.http.enable" = lib.mkDefault false;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion =
          !(
            cfg.settings ? "demo_auth.enabled"
            || cfg.settings ? "ad.enabled"
            || cfg.settings ? "ldap.enabled"
            || cfg.settings ? "embedded_ldap.enabled"
          );
        message = ''
          The Phoebus Olog settings `demo_auth.enabled`, `ad.enabled`, `ldap.enabled`, and `embedded_ldap.enabled` were removed.
          Please use `authenticationProviders` instead, and set it to "inMemory", "activeDirectory", "ldap", or "embedded_ldap" instead.
        '';
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
        ExecStart = "${lib.getExe pkgs.epnix.phoebus-olog} --spring.config.location=classpath:/application.properties,file://${configFile}";
        Type = "exec";
        Restart = "on-failure";
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
