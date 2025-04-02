{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.ca-gateway;
  pkg = pkgs.epnix.ca-gateway;

  # the CA gateway doesn't use the long/short options conventions
  mkOptionName = k: "-${k}";
  # List are for IP address lists
  mkList = k: v: [(mkOptionName k) (lib.concatStringsSep " " v)];
  toCommandLine = lib.cli.toGNUCommandLine {inherit mkOptionName mkList;};

  commandLine = lib.escapeShellArgs (toCommandLine cfg.settings);
in {
  options.services.ca-gateway = {
    enable = lib.mkEnableOption "the Channel Access PV gateway";

    openFirewall = lib.mkOption {
      description = ''
        Open the firewall for allowing Channel Access communications.

        :::{warning}
        This opens the firewall on all network interfaces.
        :::
      '';
      type = lib.types.bool;
      default = false;
    };

    settings = lib.mkOption {
      description = ''
        Configuration for the Channel Access PV gateway.

        These options are passed onto the gateway command-line.

        Available options can be seen here:
        <https://epics.anl.gov/EpicsDocumentation/ExtensionsManuals/Gateway/Gateway.html#Starting>
      '';
      default = {};
      type = lib.types.submodule {
        freeformType = with lib.types;
          nullOr (oneOf [
            bool
            int
            float
            str
            path
            (listOf str)
          ]);
        options = {
          pvlist = lib.mkOption {
            description = ''
              Name of file with all the allowed PVs in it.

              See the sample file gateway.pvlist in the source distribution
              for a description of how to create this file:

              <https://github.com/epics-extensions/ca-gateway/blob/v${pkg.version}/example/GATEWAY.pvlist>
            '';
            type = with lib.types; nullOr (either path str);
            default = null;
            example = lib.literalExpression ''
              pkgs.writeText "gateway.pvlist" '''
                EVALUATION ORDER DENY, ALLOW

                .* DENY

                MY_PV ALLOW

                # ...
              '''
            '';
          };

          access = lib.mkOption {
            description = ''
              Name of file with all the EPICS access security rules in it.

              PVs in the pvlist file use groups and rules defined in this file.

              See the sample file gateway.pvlist in the source distribution:

              <https://github.com/epics-extensions/ca-gateway/blob/v${pkg.version}/example/GATEWAY.access>
            '';
            type = with lib.types; nullOr (either path str);
            default = null;
            example = lib.literalExpression ''
              pkgs.writeText "gateway.access" '''
                UAG(GatewayAdmin)  {gateway,smith}

                # ...
              '''
            '';
          };

          sip = lib.mkOption {
            description = ''
              IP address list that gateway's CA server listens for PV requests.

              Sets env variable `EPICS_CAS_INTF_ADDR_LIST`.

              By default,
              the CA server is accessible from all network interfaces configured into its host.
            '';
            type = with lib.types; nullOr (listOf str);
            default = null;
            example = ["192.168.1.1"];
          };

          signore = lib.mkOption {
            description = ''
              IP address list that gateway's CA server ignores.

              Sets env variable `EPICS_CAS_IGNORE_ADDR_LIST`.
            '';
            type = with lib.types; nullOr (listOf str);
            default = null;
            example = ["192.168.1.5" "192.168.1.42"];
          };

          sport = lib.mkOption {
            description = ''
              The port which the gateway's CA server uses to listen for PV requests.

              Sets environment variable `EPICS_CAS_SERVER_PORT`.
            '';
            type = lib.types.port;
            default = 5064;
          };

          cip = lib.mkOption {
            description = ''
              IP address list that the gateway's CA client uses to find the real PVs.

              See the CA reference manual.

              This sets environment variables `EPICS_CA_AUTO_LIST=NO` and `EPICS_CA_ADDR_LIST`.

              :::{note}
              If you intend to broadcast on a port other than 5064,
              you will need change your firewall configuration
              and accept incoming UDP packets with your *source* port.
              :::
            '';
            type = with lib.types; nullOr (listOf str);
            default = null;
            example = ["192.168.1.4" "192.168.1.3"];
          };

          cport = lib.mkOption {
            description = ''
              The port which the gateway's CA client uses to find the real PVs.

              Sets environment variable `EPICS_CA_SERVER_PORT`.

              With `openFirewall = true`,
              this option sets the port in the firewall rule for the CA broadcast reply.
            '';
            type = lib.types.port;
            default = 5064;
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.settings ? server -> !cfg.settings.server;
        message = "the ca-gateway 'server' option is incompatible with systemd";
      }
    ];

    systemd.services.ca-gateway = {
      description = "Channel Access PV gateway";

      wantedBy = ["multi-user.target"];

      # When initializing the IOC, PV Access looks for network interfaces that
      # have IP addresses. "network.target" may be too early, especially for
      # systems with DHCP.
      wants = ["network-online.target"];
      after = ["network-online.target"];

      serviceConfig = {
        ExecStart = "${lib.getExe pkg} ${commandLine}";
        # ca-gateway doesn't always exit with a positive status code,
        # even on failure
        Restart = "always";
        DynamicUser = true;

        # Security options:
        # ---

        # NETLINK needed to enumerate available interfaces
        RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_NETLINK"];
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
        # Service cannot create writable executable memory mappings
        MemoryDenyWriteExecute = true;
        # Service has no access to non-process /proc files (/proc subset=)
        ProcSubset = "pid";
        # Service may execute system calls only with native ABI
        SystemCallArchitectures = "native";
        # Access write directories
        UMask = "0077";

        # Service can only use a reasonable set of system calls,
        # used by common system services
        SystemCallFilter = ["@system-service"];
        # Disallowed system calls return EPERM instead of terminating the service
        SystemCallErrorNumber = "EPERM";
      };
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [cfg.settings.sport];
      allowedUDPPorts = [
        cfg.settings.sport

        # Repeater port
        5065
      ];

      # Allow UDP packets coming from 5064,
      # which is needed to listen to CA broadcast responses
      extraCommands = ''
        ip46tables -A nixos-fw -p udp --sport ${toString cfg.settings.cport} -j nixos-fw-accept
      '';
    };
  };
}
