{
  config,
  epnixLib,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.recceiver;

  pkg = pkgs.python3Packages.recceiver;
  python = pkgs.python3.withPackages (
    ps: [
      ps.recceiver
      ps.twisted
    ]
  );

  settingsFormat = pkgs.formats.ini {};
  configFile = settingsFormat.generate "recceiver.conf" cfg.settings;
  channelfinderapiConfFile = settingsFormat.generate "channelfinderapi.conf" cfg.channelfinderapi;
in {
  options.services.recceiver = {
    enable = lib.mkEnableOption "the RecCeiver service";

    channelfinderapi = lib.mkOption {
      description = ''
        Configuration for the ChannelFinder client.

        See upstream documentation for all supported options:
        https://github.com/ChannelFinder/pyCFClient?tab=readme-ov-file#configuration
      '';
      default = {};
      type = lib.types.submodule {
        freeformType = settingsFormat.type;
        options.DEFAULT = {
          BaseURL = lib.mkOption {
            type = lib.types.str;
            default = "http://localhost:8080/ChannelFinder";
            description = "URL of the remote ChannelFinder server.";
          };

          username = lib.mkOption {
            type = with lib.types; nullOr str;
            default = null;
            description = "Username for authentication.";
          };

          password = lib.mkOption {
            type = with lib.types; nullOr str;
            default = null;
            description = "Password for authentication.";
          };
        };
      };
    };

    settings = lib.mkOption {
      description = ''
        Configuration for the RecCeiver service.

        See upstream documentation for all supported options:
        https://github.com/ChannelFinder/recsync/blob/${pkg.version}/server/demo.conf
      '';
      default = {};
      type = lib.types.submodule {
        freeformType = settingsFormat.type;
        options = {
          recceiver = {
            bind = lib.mkOption {
              type = lib.types.str;
              default = "0.0.0.0:0";
              description = ''
                Listen for TCP connections on this interface and port.

                Port also used as source for UDP broadcasts

                Default uses wildcard address and a random port.
              '';
            };

            addrlist = lib.mkOption {
              type = with lib.types; listOf str;
              default = ["255.255.255.255:5049"];
              apply = lib.concatStringsSep ",";
              description = ''
                Listen for TCP connections on this interface and port.

                Port also used as source for UDP broadcasts

                Default uses wildcard address and a random port.
              '';
            };

            procs = lib.mkOption {
              type = with lib.types; listOf str;
              default = ["show"];
              example = ["show" "cf"];
              apply = lib.concatStringsSep ",";
              description = ''
                Processing chain, sequence of plugin names.

                Plugin names may be followed by an instance name (eg. ``db:arbitrary``)
                which allows for more than one instance of a plugin with different
                configuration.

                Default plugins:

                ``show``
                   Prints information to daemon log

                ``db``
                   Stores in sqlite3 database

                ``cf``
                   Stores in a ChannelFinder server
              '';
            };
          };

          cf = {
            environment_vars = lib.mkOption {
              type = with lib.types; attrsOf str;
              default = {};
              example = {
                ENGINEER = "Engineer";
                EPICS_BASE = "EpicsVersion";
                PWD = "WorkingDirectory";
              };
              apply = val: lib.concatStringsSep "," (lib.mapAttrsToList (k: v: "${k}:${v}") val);
              description = ''
                Attribute set of ``VARIABLE = "PropertyName";``

                Specifies which environment ``VARIABLEs`` to pass on to the ChannelFinder server,
                and defining the corresponding ``PropertyName``.
              '';
            };
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.recceiver = {
      inherit (pkg.meta) description;

      wantedBy = ["multi-user.target"];
      after = ["channel-finder.service"];

      preStart = ''
        ln -sfn "${channelfinderapiConfFile}" "$STATE_DIRECTORY/channelfinderapi.conf"
      '';

      serviceConfig = {
        ExecStart = "${python}/bin/twistd --nodaemon --no_save --reactor=poll --pidfile= --logfile=- recceiver --config=${configFile}";
        DynamicUser = true;
        Restart = "on-failure";
        StateDirectory = "recceiver";

        # channelfinderapi.conf needs to be in the working directory
        WorkingDirectory = "/var/lib/recceiver";

        # Security options:
        # ---

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
        # Service may not create writable executable memory mappings
        MemoryDenyWriteExecute = true;

        # Service can only use a reasonable set of system calls,
        # used by common system services
        SystemCallFilter = ["@system-service"];
        # Disallowed system calls return EPERM instead of terminating the service
        SystemCallErrorNumber = "EPERM";
      };
    };
  };

  meta.maintainers = with epnixLib.maintainers; [minijackson];
}
