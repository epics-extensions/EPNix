{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.iocs;

  iocSubmodule = {
    name,
    config,
    ...
  }: {
    options = {
      enable = lib.mkOption {
        description = "Whether to enable the given IOC.";
        type = lib.types.bool;
        default = true;
      };

      name = lib.mkOption {
        description = "The name of the IOC, used for the systemd service.";
        type = lib.types.str;
        default = name;
      };

      description = lib.mkOption {
        description = "A description for your EPICS IOC";
        type = lib.types.str;
        default = config.package.meta.description or "";
        defaultText = lib.literalExpression ''package.meta.description or "EPICS IOC"'';
      };

      package = lib.mkOption {
        description = "The packaged EPICS top containing the IOC.";
        type = lib.types.package;
        example = lib.literalExpression "pkgs.myIoc";
      };

      startupScript = lib.mkOption {
        description = ''
          The script used to start the IOC.

          The path is relative to the given {nix:option}`workingDirectory`.
        '';
        type = lib.types.str;
        default = "./st.cmd";
        example = "./other-st.cmd";
      };

      workingDirectory = lib.mkOption {
        description = "The working directory from which to start the IOC.";
        example = "iocBoot/iocExample";
      };

      procServ = {
        port = lib.mkOption {
          default = 2000;
          type = lib.types.port;
          description = ''
            Port where the procServ utility will listen.
          '';
        };

        options = lib.mkOption {
          default = {};
          example = {
            allow = true;
            info-file = "/var/run/ioc/procServ_info";
          };
          type = with lib.types; attrsOf (oneOf [str int bool (listOf str)]);
          description = ''
            Extra command-line options to pass to procServ.

            :::{note}
            using `lib.mkForce` overrides the default options needed
            for the systemd service to work.
            If you wish to do this,
            you need to specify needed arguments
            like `foreground` and `chdir`.
            :::
          '';
        };
      };

      # Re-exposed systemd options:

      environment = lib.mkOption {
        description = "Environment variables passed to the IOC process";
        type = with lib.types; attrsOf (nullOr (oneOf [str path package]));
        default = {};
        example = {
          EPICS_CA_MAX_ARRAY_BYTES = 10000;
          AUTOSAVE_DIRECTORY = "/var/lib/epics/myIoc/autosave";
        };
      };

      path = lib.mkOption {
        description = ''
          Packages added to the service's `PATH` environment variable.

          Both the {file}`bin` and {file}`sbin` subdirectories of each package are added.
        '';
        type = with lib.types; listOf (oneOf [package str]);
        default = [];
        example = lib.literalExpression ''
          [
            pkgs.pciutils
          ]
        '';
      };

      # ---

      generatedSystemdService = lib.mkOption {
        description = "The generated systemd service.";
        internal = true;
        type = lib.types.attrs;
      };

      generatedTelnetScript = lib.mkOption {
        description = "The generated telnet script package.";
        internal = true;
        type = lib.types.package;
      };
    };

    config = {
      environment.EPICS_IOCSH_HISTFILE = "/var/lib/epics/${name}/iocsh_history";

      procServ.options = {
        foreground = true;
        oneshot = true;
        logfile = "-";
        holdoff = 0;
        chdir = "${config.package}/${config.workingDirectory}";
      };

      generatedSystemdService = {
        inherit (config) description environment path;

        wantedBy = lib.mkIf config.enable (lib.mkDefault ["multi-user.target"]);

        # When initializing the IOC,
        # PV Access looks for network interfaces that have IP addresses.
        # "network.target" may be too early,
        # especially for systems with DHCP.
        wants = lib.mkDefault ["network-online.target"];
        after = lib.mkDefault ["network-online.target"];

        # Enable indefinite restarts
        unitConfig.StartLimitIntervalSec = lib.mkDefault "0";

        serviceConfig = {
          ExecStart = let
            procServ = lib.getExe pkgs.epnix.procServ;
          in ''
            ${procServ} ${lib.cli.toGNUCommandLineShell {} config.procServ.options} \
              ${toString config.procServ.port} \
              ${config.startupScript}
          '';

          Restart = lib.mkDefault "always";
          RestartSec = lib.mkDefault "1s";
          StateDirectory = ["epics/${name}"];

          # Hardening options,
          # can be disabled by the end user, if needed

          DynamicUser = lib.mkDefault true;

          PrivateUsers = lib.mkDefault true;
          PrivateMounts = lib.mkDefault true;

          ProtectKernelLogs = lib.mkDefault true;
          ProtectKernelModules = lib.mkDefault true;
          ProtectKernelTunables = lib.mkDefault true;
          ProtectClock = lib.mkDefault true;
          ProtectControlGroups = lib.mkDefault true;
          ProtectHostname = lib.mkDefault true;
          ProtectHome = lib.mkDefault true;
          ProtectProc = lib.mkDefault true;

          RestrictNamespaces = lib.mkDefault true;

          LockPersonality = lib.mkDefault true;

          SystemCallArchitectures = lib.mkDefault "native";

          # Don't allow these syscalls by default
          SystemCallFilter = lib.mkDefault [
            "~@clock"
            "~@cpu-emulation"
            "~@debug"
            "~@module"
            "~@obsolete"
            "~@reboot"
            "~@swap"
          ];
          # Don't allow these capabilities by default
          CapabilityBoundingSet = lib.mkDefault [
            "~CAP_SYS_PACCT"
            "~CAP_SETUID"
            "~CAP_SETGID"
            "~CAP_SETPCAP"
            "~CAP_SYS_PTRACE"
            "~CAP_NET_ADMIN"
            "~CAP_SYS_ADMIN"
          ];
        };
      };

      generatedTelnetScript = pkgs.writeShellApplication {
        name = "telnet-${name}";
        runtimeInputs = [pkgs.inetutils];
        text = ''
          telnet localhost ${toString config.procServ.port} "$@"
        '';
      };
    };
  };
in {
  options.services.iocs = lib.mkOption {
    description = ''
      A set of IOCs for which to generate a systemd service

      :::{versionadded} 25.05
      :::
    '';
    type = lib.types.attrsOf (lib.types.submodule iocSubmodule);
    default = {};
    example = lib.literalExpression ''
      {
        myIoc = {
          package = pkgs.myIoc;
          workingDirectory = "iocBoot/iocExample";
        };
      };
    '';
  };

  config = {
    systemd.services =
      lib.mapAttrs'
      (_name: iocCfg: {
        inherit (iocCfg) name;
        value = iocCfg.generatedSystemdService;
      })
      cfg;

    environment.systemPackages = lib.mkMerge [
      # If there's at least one IOC configured,
      # add telnet to the environment,
      # to be able to connect to procServ
      (lib.mkIf (cfg != {}) [pkgs.inetutils])

      # The generated telnet scripts
      (lib.mapAttrsToList (_name: config: config.generatedTelnetScript) cfg)
    ];
  };
}
