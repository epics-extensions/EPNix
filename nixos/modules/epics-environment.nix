{
  config,
  lib,
  ...
}:
let
  cfg = config.environment.epics;
in
{
  options.environment.epics = {
    enable = lib.mkOption {
      description = ''
        Whether to configure EPICS-related environment variables.

        :::{seealso}
        [EPICS environment variables] in the Channel Access Reference Manual.
        :::

          [EPICS environment variables]: https://epics.anl.gov/base/R7-0/8-docs/CAref.html#EPICS
      '';
      type = lib.types.bool;
      default = true;
    };

    ca_auto_addr_list = lib.mkOption {
      description = ''
        Set the `EPICS_CA_AUTO_ADDR_LIST` environment variable.

        This will also set this configuration for related services,
        for example IOCs, ChannelFinder, and Phoebus services.

        :::{seealso}
        [EPICS environment variables] in the Channel Access Reference Manual.
        :::
      '';
      type = lib.types.bool;
      default = true;
    };

    ca_addr_list = lib.mkOption {
      description = ''
        Set the `EPICS_CA_ADDR_LIST` environment variable.

        This will also set this configuration for related services,
        for example IOCs, ChannelFinder, and Phoebus services.

        :::{seealso}
        [EPICS environment variables] in the Channel Access Reference Manual.
        :::
      '';
      type = with lib.types; listOf str;
      default = [ ];
    };
    openCAFirewall = lib.mkOption {
      description = ''
        This option enable the default ports of the Channel Access protocol.
        If in your IOC you manually change the ports.
        You will need to open them manually.
        With the NixOS option {nix:option}`networking.firewall.allowedTCPPorts` & {nix:option}`networking.firewall.allowedUDPPorts`
      '';
      type = lib.types.bool;
      default = false;

    };
    openPVAFirewall = lib.mkOption {
      description = ''
        This option enable the default ports of the pvAccess protocol.
        If in your IOC you manually change the ports.
        You will need to open them manually.
        With the NixOS option {nix:option}`networking.firewall.allowedTCPPorts` & {nix:option}`networking.firewall.allowedUDPPorts`
      '';
      type = lib.types.bool;
      default = false;
    };
    allowBroadcastDiscovery = lib.mkOption {
      description = ''
        This option allow the network discovery of the IOC proccess on the default port.
        But this option is an security issue about the a possibility
        to attack the host by crafting an malicious packet with the source port of the IOC.'';
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.sessionVariables = {
      EPICS_CA_AUTO_ADDR_LIST = if cfg.ca_auto_addr_list then "YES" else "NO";
      EPICS_CA_ADDR_LIST = lib.concatStringsSep " " cfg.ca_addr_list;
    };

    networking.firewall = lib.mkMerge [
      (lib.mkIf cfg.openCAFirewall {
        allowedTCPPorts = [
          5064
          5065
        ];
        allowedUDPPorts = [
          5064
          5065
        ];
      })
      (lib.mkIf cfg.openPVAFirewall {
        allowedTCPPorts = [ 5076 ];
        allowedUDPPorts = [ 5076 ];
      })
      (lib.mkIf cfg.allowBroadcastDiscovery {
        extraCommands = ''
          ip46tables -A nixos-fw -p udp --sport 5064 -j nixos-fw-accept
        '';
      })
    ];
  };
}
