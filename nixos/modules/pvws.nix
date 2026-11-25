{
  config,
  epnixLib,
  lib,
  options,
  pkgs,
  ...
}:
let
  cfg = config.services.pvws;
  opt = options.services.pvws;
  settingsFormat = pkgs.formats.javaProperties { };
  configFile = settingsFormat.generate "pvws.properties" cfg.settings;
in
{
  options.services.pvws = {
    enable = lib.mkEnableOption "the PV WebSocket service";

    package = lib.mkPackageOption pkgs "PVWS" {
      default = [
        "epnix"
        "pvws"
      ];
    };

    openFirewall = lib.mkOption {
      description = ''
        Open the firewall for the PVWS service.

        :::{warning}
        This opens the firewall on all network interfaces.
        :::
      '';
      type = lib.types.bool;
      default = false;
    };

    websocketBufferSize = lib.mkOption {
      description = ''
        Maximum size of websocket buffers, in bytes.

        This value can be increased
        in the case the maximum message size is hit
        when subscribing to a large number of PVs.
      '';
      type = lib.types.int;
      default = 8192;
      example = 131072;
    };

    settings = lib.mkOption {
      description = ''
        Configuration for PVWS.

        These options will be passed in a properties file.

        See the [default `application.properties` of PVWS](https://github.com/ControlSystemStudio/pvws/blob/master/src/main/resources/application.properties)
        for a complete list of options and default values.
      '';
      default = { };
      type = lib.types.submodule {
        freeformType =
          with lib.types;
          attrsOf (oneOf [
            str
            path
          ]);
        options = {
          "server.port" = lib.mkOption {
            type = with lib.types; coercedTo port toString str;
            default = 8080;
            description = "The HTTP server port for PVWS.";
          };

          EPICS_PVA_ADDR_LIST = lib.mkOption {
            description = ''
              List of pvAccess destination IP addresses.

              Each IP address can be a unicast address,
              or a broadcast address.

              Use `lib.mkForce` to override values from {nix:option}`environment.epics.pva_addr_list`.
            '';
            # Separated by spaces -> toString
            type = with lib.types; coercedTo (listOf str) toString str;
            defaultText = lib.literalExpression ''
              if config.environment.epics.enable
              then config.environment.epics.pva_addr_list
              else [];
            '';
          };

          EPICS_PVA_AUTO_ADDR_LIST = lib.mkOption {
            description = ''
              If set,
              behave as if every broadcast address of every network interface is added to `EPICS_PVA_ADDR_LIST`.

              Use `lib.mkForce` to override values from {nix:option}`environment.epics.pva_auto_addr_list`.
            '';
            type = with lib.types; coercedTo bool lib.boolToYesNo str;
            defaultText = lib.literalExpression ''
              if config.environment.epics.enable
              then config.environment.epics.pva_auto_addr_list
              else [];
            '';
          };

          PV_DEFAULT_TYPE = lib.mkOption {
            description = "Default PV type.";
            type = lib.types.str;
            default = "ca";
            example = "pva";
          };

          PV_WRITE_SUPPORT = lib.mkOption {
            description = "Whether to enable PV write support.";
            type = with lib.types; coercedTo bool lib.boolToString str;
            default = false;
            example = true;
          };
        };
      };
    };

    environment = lib.mkOption {
      description = ''
        Environment variables passed to PVWS.

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
      defaultText = lib.literalExpression ''
        {
          EPICS_CA_ADDR_LIST =
            if config.environment.epics.enable then toString config.environment.epics.ca_addr_list else "";
          EPICS_CA_AUTO_ADDR_LIST =
            if config.environment.epics.enable then lib.boolToString config.environment.epics.ca_auto_addr_list else "true";
        }
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !(cfg.settings ? EPICS_CA_ADDR_LIST || cfg.settings ? EPICS_CA_AUTO_ADDR_LIST);
        message = ''
          pvws: `settings.EPICS_CA_ADDR_LIST` and `settings.EPICS_CA_AUTO_ADDR_LIST` defined in ${lib.showFiles opt.settings.files}
          cannot be specified in `settings`, they must be defined in `environment`.'';
      }
    ];

    services.pvws = {
      environment = {
        EPICS_CA_ADDR_LIST =
          if config.environment.epics.enable then toString config.environment.epics.ca_addr_list else "";
        EPICS_CA_AUTO_ADDR_LIST =
          if config.environment.epics.enable then
            lib.boolToString config.environment.epics.ca_auto_addr_list
          else
            "true";
      };
      settings = {
        EPICS_PVA_ADDR_LIST =
          if config.environment.epics.enable then config.environment.epics.pva_addr_list else [ ];
        EPICS_PVA_AUTO_ADDR_LIST =
          if config.environment.epics.enable then config.environment.epics.pva_auto_addr_list else true;
      };
    };

    systemd.services.pvws = {
      description = "PV Web Socket";

      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      inherit (cfg) environment;

      serviceConfig = {
        ExecStart = "${lib.getExe pkgs.epnix.pvws} --spring.config.location=classpath:/application.properties,file://${configFile}";
        Type = "exec";
        Restart = "on-failure";
        DynamicUser = true;

        # Security options:
        # ---

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

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [
      (lib.toInt cfg.settings."server.port")
    ];
  };

  meta.maintainers = with epnixLib.maintainers; [ minijackson ];
}
