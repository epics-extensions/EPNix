{
  config,
  epnixLib,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.channel-finder;
  settingsFormat = pkgs.formats.javaProperties { };
  configFile = settingsFormat.generate "channel-finder.properties" cfg.settings;
in
{
  options.services.channel-finder = {
    enable = lib.mkEnableOption "the ChannelFinder service";

    openFirewall = lib.mkOption {
      description = ''
        Open the firewall for the ChannelFinder service.

        :::{warning}
        This opens the firewall on all network interfaces.
        :::

        This option opens firewall for the HTTP/HTTPS API,
        and pvAccess server.
      '';
      type = lib.types.bool;
      default = false;
    };

    settings = lib.mkOption {
      description = ''
        Configuration for the ChannelFinder service.

        These options will be put into a `.properties` file.

        Note that options containing a "." must be quoted.

        See upstream documentation for all supported options:
        <https://channelfinder.readthedocs.io/en/latest/config.html#application-properties>

      '';
      default = { };
      type = lib.types.submodule {
        freeformType = settingsFormat.type;
        options = {
          "server.port" = lib.mkOption {
            type = lib.types.port;
            default = 8443;
            # TODO: Weirdness of the javaProperties format?
            # It says it supports integers and booleans, but during the build
            # only accepts strings?
            apply = toString;
            description = "The HTTPS server port for the ChannelFinder service";
          };

          "server.http.enable" = lib.mkOption {
            type = lib.types.bool;
            default = true;
            apply = lib.boolToString;
            description = "Enable unsecure HTTP";
          };

          "server.http.port" = lib.mkOption {
            type = lib.types.port;
            default = 8080;
            apply = toString;
            description = "The HTTP server port for the ChannelFinder service";
          };

          "elasticsearch.host_urls" = lib.mkOption {
            type = with lib.types; listOf str;
            default = [ "http://localhost:9200" ];
            description = ''
              List of URLs for the Elasticsearch hosts.

              All hosts listed here must belong to the same Elasticsearch cluster.
            '';
            apply = lib.concatStringsSep ",";
          };

          "elasticsearch.create.indices" = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = ''
              List of URLs for the Elasticsearch hosts.

              All hosts listed here must belong to the same Elasticsearch cluster.
            '';
            apply = lib.boolToString;
          };

          "demo_auth.enabled" = lib.mkOption {
            type = lib.types.bool;
            default = false;
            apply = lib.boolToString;
            description = ''
              Enable the demo authentication.

              ChannelFinder will provide two users:

              - `admin:adminPass`
              - `user:userPass`
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
          settings."ldap.enabled" == "true"
          || settings."embedded_ldap.enabled" == "true"
          || settings."demo_auth.enabled" == "true";
        message = "One type of authentication for ChannelFinder must be provided";
      }
    ];

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [
        (lib.toInt cfg.settings."server.port")
        (lib.mkIf (cfg.settings."server.http.enable" == "true") (
          lib.toInt cfg.settings."server.http.port" or "8080"
        ))

        # pvAccess
        5075
      ];
      allowedUDPPorts = [ 5076 ];
    };

    systemd.services.channel-finder = {
      inherit (pkgs.epnix.channel-finder-service.meta) description;

      wantedBy = [ "multi-user.target" ];
      after = [ "elasticsearch.service" ];

      serviceConfig = {
        ExecStart = "${lib.getExe pkgs.epnix.channel-finder-service} --spring.config.location=file://${configFile}";
        DynamicUser = true;
        Restart = "on-failure";

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
  };

  meta.maintainers = with epnixLib.maintainers; [ minijackson ];
}
