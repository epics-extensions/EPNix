{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.pva-gateway;
  settingsFormat = pkgs.formats.json { };
  configFile = settingsFormat.generate "pva-gateway.json" cfg.settings;
  inherit (pkgs.python3Packages) p4p;
in
{
  options.services.pva-gateway = {
    enable = lib.mkEnableOption "the PVA gateway";

    settings = lib.mkOption {
      description = ''
        Configuration for the PVA gateway.

        See the [PVA gateway configuration file documentation](https://epics-base.github.io/p4p/gw.html#configuration-file)
        for a complete list of available settings.
      '';
      type = lib.types.submodule {
        freeformType = settingsFormat.type;
        options = {
          version = lib.mkOption {
            description = "Version of the configuration.";
            type = lib.types.int;
            default = 2;
          };

          clients = lib.mkOption {
            description = "List of pvAccess clients.";
            example = [ { name = "broadcast-client"; } ];
            type = lib.types.listOf (
              lib.types.submodule {
                freeformType = settingsFormat.type;
                options = {
                  name = lib.mkOption {
                    description = "Name for the pvAccess client.";
                    type = lib.types.str;
                    example = "client192";
                  };

                  autoaddrlist = lib.mkOption {
                    description = "Sets `EPICS_PVA_AUTO_ADDR_LIST` for this client.";
                    type = lib.types.bool;
                    default = true;
                  };

                  addrlist = lib.mkOption {
                    description = "Sets `EPICS_PVA_ADDR_LIST` for this client.";
                    type = with lib.types; coercedTo (listOf str) toString str;
                    default = [ ];
                    example = [ "192.168.0.255" ];
                  };
                };
              }
            );
          };

          servers = lib.mkOption {
            description = "List of pvAccess servers.";
            example = [ { name = "any-server"; } ];
            type = lib.types.listOf (
              lib.types.submodule {
                freeformType = settingsFormat.type;
                options = {
                  name = lib.mkOption {
                    description = "Name for the pvAccess server.";
                    type = lib.types.str;
                    example = "server10";
                  };

                  clients = lib.mkOption {
                    description = "This server serves PVs that are obtained from the given clients.";
                    type = with lib.types; listOf str;
                    example = [ "client192" ];
                  };

                  interface = lib.mkOption {
                    description = ''
                      Which local IP addresses this server listens on.

                      Sets the `EPICS_PVAS_INTF_ADDR_LIST` environment variable.
                    '';
                    type = with lib.types; listOf str;
                    default = [ "0.0.0.0" ];
                    example = [ "10.1.1.4" ];
                  };

                  addrlist = lib.mkOption {
                    description = ''
                      List of IP addresses where to send beacons.

                      Sets the `EPICS_PVAS_BEACON_ADDR_LIST` environment variable.
                    '';
                    type = with lib.types; coercedTo (listOf str) toString str;
                    default = [ ];
                    example = [ "10.1.1.255" ];
                  };

                  autoaddrlist = lib.mkOption {
                    description = ''
                      Whether to populate the beacon address list automatically. (recommended)

                      Sets `EPICS_PVAS_AUTO_BEACON_ADDR_LIST` for this client.
                    '';
                    type = lib.types.bool;
                    default = true;
                  };

                  statusprefix = lib.mkOption {
                    description = "Prefix for the gateway status PVs.";
                    type = with lib.types; nullOr str;
                    default = null;
                    example = "GW:STS:";
                  };

                  pvlist = lib.mkOption {
                    description = "PVList file used to restrict access to certain PVs through this server";
                    type = with lib.types; either path str;
                    default = "";
                    example = lib.literalExpression ''
                      pkgs.writeText "gateway.pvlist" '''
                        EVALUATION ORDER ALLOW, DENY

                        .* ALLOW

                        MY_PV1 DENY
                        MY_PV2 DENY

                        # Or:

                        MY_PV[0-9]+ DENY
                      '''
                    '';
                  };
                };
              }
            );
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    system.checks = [
      (pkgs.runCommand "test-pva-gateway-config"
        {
          nativeBuildInputs = [ p4p ];
        }
        ''
          pvagw --test-config ${configFile}
          touch $out
        ''
      )
    ];

    systemd.services.pva-gateway = {
      description = "PVA gateway";

      wantedBy = [ "multi-user.target" ];

      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      serviceConfig = {
        ExecStart = "${lib.getExe' p4p "pvagw"} ${configFile}";
        Type = "exec";
        Restart = "always";
        DynamicUser = true;

        # Security options:
        # ---

        # NETLINK needed to enumerate available interfaces
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
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
        SystemCallFilter = [ "@system-service" ];
        # Disallowed system calls return EPERM instead of terminating the service
        SystemCallErrorNumber = "EPERM";
      };
    };
  };
}
