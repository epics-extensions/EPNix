{
  config,
  epnixLib,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.phoebus-save-and-restore;
  settingsFormat = pkgs.formats.javaProperties {};
  configFile = settingsFormat.generate "phoebus-save-and-restore.properties" cfg.settings;
in {
  options.services.phoebus-save-and-restore = {
    enable = lib.mkEnableOption ''
      the Phoebus Save-and-restore service.

      This service is used by clients
      to manage configurations (aka save sets) and snapshots,
      to compare snapshots,
      and to restore PV values from snapshots'';

    openFirewall = lib.mkOption {
      description = ''
        Open the firewall for the Phoebus Save-and-restore service.

        :::{warning}
        This opens the firewall on all network interfaces.
        :::
      '';
      type = lib.types.bool;
      default = false;
    };

    settings = lib.mkOption {
      description = ''
        Configuration for the Phoebus Save-and-restore service.

        These options will be put into a `.properties` file.

        Note that options containing a "." must be quoted.

        Available options can be seen here:
        <https://github.com/ControlSystemStudio/phoebus/blob/v${pkgs.epnix.phoebus-save-and-restore.version}/services/save-and-restore/src/main/resources/application.properties>
      '';
      default = {};
      type = lib.types.submodule {
        freeformType = settingsFormat.type;
        options = {
          "server.port" = lib.mkOption {
            description = "Port for the Save-and-restore service";
            type = lib.types.port;
            default = 8080;
            apply = toString;
          };

          "auth.impl" = lib.mkOption {
            description = ''
              Authentication implementation.

              Supported options:

              `"ad"`
              :   Microsoft Active Directory

              `"ldap"`
              :   LDAP

              `"ldap_embedded"`
              :   Embedded LDAP. Config in sar.ldif

              `"demo"`
              :   Hard coded users and passwords.
                  Provides 3 users:

                  -   an admin
                  -   a read-only user
                  -   a normal user

                  See the following options:

                  -   {nix:option}`"demo.admin"`
                  -   {nix:option}`"demo.admin.password"`
                  -   {nix:option}`"demo.readOnly"`
                  -   {nix:option}`"demo.readOnly.password"`
                  -   {nix:option}`"demo.user"`
                  -   {nix:option}`"demo.user.password"`
            '';
            type = lib.types.enum ["ad" "ldap" "ldap_embedded" "demo"];
          };

          "demo.user" = lib.mkOption {
            description = ''
              Username for the normal demo user.

              Only valid for if {nix:option}`"auth.impl"` is `"demo"`.
            '';
            type = lib.types.str;
            default = "user";
          };

          "demo.user.password" = lib.mkOption {
            description = ''
              Password for the normal demo user.

              Only valid for if {nix:option}`"auth.impl"` is `"demo"`.
            '';
            type = lib.types.str;
            default = "userPass";
          };

          "demo.admin" = lib.mkOption {
            description = ''
              Username for the admin demo user.

              Only valid for if {nix:option}`"auth.impl"` is `"demo"`.
            '';
            type = lib.types.str;
            default = "admin";
          };

          "demo.admin.password" = lib.mkOption {
            description = ''
              Password for the admin demo user.

              Only valid for if {nix:option}`"auth.impl"` is `"demo"`.
            '';
            type = lib.types.str;
            default = "adminPass";
          };

          "demo.readOnly" = lib.mkOption {
            description = ''
              Username for the normal demo user.

              Only valid for if {nix:option}`"auth.impl"` is `"demo"`.
            '';
            type = lib.types.str;
            default = "johndoe";
          };

          "demo.readOnly.password" = lib.mkOption {
            description = ''
              Password for the read-only demo user.

              Only valid for if {nix:option}`"auth.impl"` is `"demo"`.
            '';
            type = lib.types.str;
            default = "1234";
          };

          "spring.ldap.embedded.ldif" = lib.mkOption {
            description = ''
              Path to [LDIF] file describing the content of the embedded LDAP server.

              Only valid for if {nix:option}`"auth.impl"` is `"embedded_ldap"`.

                [LDIF]: https://en.wikipedia.org/wiki/LDAP_Data_Interchange_Format
            '';
            type = lib.types.str;
            default = "classpath:sar.ldif";
            example = lib.literalExpression ''"file://''${./sar.ldif}"'';
          };

          "elasticsearch.network.host" = lib.mkOption {
            description = ''
              Elasticsearch server host.

              If `localhost` (the default),
              the Elasticsearch service will be automatically set up.
            '';
            type = lib.types.str;
            default = "localhost";
          };

          "elasticsearch.http.port" = lib.mkOption {
            description = "Elasticsearch server port.";
            type = lib.types.port;
            default = config.services.elasticsearch.port;
            defaultText = lib.literalExpression "config.services.elasticsearch.port";
            apply = toString;
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.phoebus-save-and-restore = {
      description = "Phoebus Save-and-restore";

      wantedBy = ["multi-user.target"];
      after = ["elasticsearch.service"];

      serviceConfig = {
        ExecStart = "${lib.getExe pkgs.epnix.phoebus-save-and-restore} --spring.config.location=file://${configFile}";
        Restart = "on-failure";
        DynamicUser = true;

        # Security options:
        # ---

        # NETLINK needed to enumerate available interfaces
        RestrictAddressFamilies = ["AF_INET" "AF_INET6"];
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
        SystemCallFilter = ["@system-service"];
        # Disallowed system calls return EPERM instead of terminating the service
        SystemCallErrorNumber = "EPERM";
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [
      (lib.toInt cfg.settings."server.port")
    ];
  };

  meta.maintainers = with epnixLib.maintainers; [minijackson];
}
