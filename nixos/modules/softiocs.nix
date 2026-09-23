{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.softIocs;
  globalCfg = config;

  softIocSubmodule =
    {
      config,
      name,
      options,
      ...
    }:
    {
      options = {
        enable = lib.mkOption {
          description = "Whether to enable the given Soft IOC.";
          type = lib.types.bool;
          default = true;
        };

        name = lib.mkOption {
          description = "The name of the Soft IOC, used for the systemd service.";
          type = lib.types.str;
          default = name;
        };

        description = lib.mkOption {
          description = "A description for your EPICS Soft IOC.";
          type = with lib.types; nullOr str;
          default = null;
          example = "My super documented SoftIOC";
        };

        dbFiles = lib.mkOption {
          description = "Load database records from the given files.";
          type = with lib.types; listOf path;
          default = [ ];
          example = lib.literalExpression "[ ./mySoftIOC.db ]";
        };

        dbText = lib.mkOption {
          description = "Load database records from the given string.";
          type = with lib.types; nullOr lines;
          default = null;
          example = ''
            record(ai, MY_PV) {
              # ...
            }
          '';
        };

        macros = lib.mkOption {
          description = "Set of macros definitions that will be expanded in the loaded files.";
          type = with lib.types; attrsOf str;
          default = { };
          example = {
            P = "MY:PREFIX:";
            CALC = "2 + 2";
          };
        };

        pvAccess.enable = lib.mkEnableOption "PV Access support";

        # TODO .acf
        # TODO .dbd
        # TODO exit PV

        environment = lib.mkOption {
          description = ''
            Environment variables passed to the Soft IOC process.

            :::{seealso}
            If enabled,
            which is the default,
            it will inherit environment variables from {nix:option}`environment.epics`.

            If you want to configure the CA address list,
            prefer using the {nix:option}`environment.epics` options.
            :::
          '';
          type =
            with lib.types;
            attrsOf (
              nullOr (oneOf [
                str
                path
                package
              ])
            );
          default = { };
          example = {
            EPICS_CA_MAX_ARRAY_BYTES = "10000";
            EPICS_CAS_SERVER_PORT = "5066";
          };
        };

        # ---

        generatedSystemdService = lib.mkOption {
          description = "The generated systemd service.";
          internal = true;
          type = lib.types.attrs;
        };
      };

      config = {
        dbFiles = lib.mkIf (config.dbText != null) [
          (lib.mkDerivedConfig options.dbText (pkgs.writeText "${name}.db"))
        ];

        environment = lib.mkIf globalCfg.environment.epics.enable {
          inherit (globalCfg.environment.variables)
            EPICS_CA_AUTO_ADDR_LIST
            EPICS_CA_ADDR_LIST
            EPICS_PVA_AUTO_ADDR_LIST
            EPICS_PVA_ADDR_LIST
            ;
        };

        generatedSystemdService = {
          inherit (config) environment;

          description = lib.mkIf (config.description != null) config.description;

          wantedBy = lib.mkIf config.enable (lib.mkDefault [ "multi-user.target" ]);

          wants = lib.mkDefault [ "network-online.target" ];
          after = lib.mkDefault [ "network-online.target" ];

          # Enable indefinite restarts
          unitConfig.StartLimitIntervalSec = lib.mkDefault "0";

          serviceConfig = {
            ExecStart =
              let
                runner =
                  if config.pvAccess.enable then
                    # Use the softIoc from PVXS, the one from epics-base seems to have issues.
                    lib.getExe' pkgs.epnix.support.pvxs "softIocPVX"
                  else
                    lib.getExe' pkgs.epnix.epics-base "softIoc";
                args = [
                  "-S"
                ]
                ++ (lib.optional (config.macros != { }) (
                  "-m" + (lib.concatMapAttrsStringSep "," (name: value: "${name}=${value}") config.macros)
                ))
                ++ (map (f: "-d${f}") config.dbFiles);
              in
              "${runner} ${lib.escapeShellArgs args}";
            Type = "exec";
            SyslogIdentifier = "${name}";
            Restart = lib.mkDefault "always";
            RestartSec = lib.mkDefault "1s";

            # Hardening options,
            # can be disabled by the end user, if needed

            DynamicUser = lib.mkDefault true;

            PrivateDevices = lib.mkDefault true;
            PrivateUsers = lib.mkDefault true;
            PrivateMounts = lib.mkDefault true;

            ProtectKernelLogs = lib.mkDefault true;
            ProtectKernelModules = lib.mkDefault true;
            ProtectKernelTunables = lib.mkDefault true;
            ProtectClock = lib.mkDefault true;
            ProtectControlGroups = lib.mkDefault true;
            ProtectHostname = lib.mkDefault true;
            ProtectHome = lib.mkDefault true;
            ProtectProc = lib.mkDefault "invisible";

            RestrictNamespaces = lib.mkDefault true;
            RestrictAddressFamilies = lib.mkDefault [
              "AF_INET"
              "AF_INET6"
              "AF_NETLINK"
            ];

            LockPersonality = lib.mkDefault true;
            MemoryDenyWriteExecute = true;
            ProcSubset = "pid";
            SystemCallArchitectures = lib.mkDefault "native";
            UMask = "177";

            # Don't allow these syscalls by default
            SystemCallFilter = lib.mkDefault [
              "~@clock"
              "~@cpu-emulation"
              "~@debug"
              "~@module"
              "~@mount"
              "~@obsolete"
              "~@privileged"
              "~@raw-io"
              "~@reboot"
              "~@swap"
            ];
            # Don't allow any capability by default
            CapabilityBoundingSet = lib.mkDefault [ "" ];
          };
        };
      };
    };
in
{
  options.services.softIocs = lib.mkOption {
    description = "A set of SoftIOCs for which to generate a systemd service.";
    type = lib.types.attrsOf (lib.types.submodule softIocSubmodule);
    default = { };
    example = lib.literalExpression ''
      {
        mySoftIoc.dbText = '''
          record(ai, MY_PV) {
            # ...
          }
        ''';
      };
    '';
  };

  config = {
    systemd.services = lib.mapAttrs' (_name: iocCfg: {
      inherit (iocCfg) name;
      value = iocCfg.generatedSystemdService;
    }) cfg;
  };
}
