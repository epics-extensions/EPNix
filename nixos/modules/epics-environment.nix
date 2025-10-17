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
        Open the default ports of the Channel Access protocol.

        Enabling this option makes IOCs reachable using unicast addresses.

        To make it discoverable with the auto address list / broadcast addresses,
        use the {nix:option}`allowCABroadcastDiscovery` option
        on the client side.

        :::{warning}
        This opens the firewall on all network interfaces.
        :::

        :::{note}
        If you changed the Channel Access ports in your IOC,
        open these ports in the firewall manually
        by using `networking.firewall.allowedTCPPorts`
        and `networking.firewall.allowedUDPPorts`.
        :::
      '';
      type = lib.types.bool;
      default = false;
    };

    openPVAFirewall = lib.mkOption {
      description = ''
        Open the default ports of the pvAccess protocol.

        Enabling this option makes IOCs reachable using unicast addresses.

        To make it discoverable with the auto address list / broadcast addresses,
        use the {nix:option}`allowPVABroadcastDiscovery` option
        on the client side.

        :::{warning}
        This opens the firewall on all network interfaces.
        :::

        :::{note}
        If you changed the pvAccess ports in your IOC,
        open these ports in the firewall manually
        by using `networking.firewall.allowedTCPPorts`
        and `networking.firewall.allowedUDPPorts`.
        :::
      '';
      type = lib.types.bool;
      default = false;
    };

    allowCABroadcastDiscovery = lib.mkOption {
      description = ''
        This option allows the broadcast discovery of Channel Access IOCs on the default port.

        :::{danger}
        This option is a security issue
        and attackers crafting a malicious packet from source port 5064
        will be able to access any [Ephemeral port]
        of this machine.
        :::

        :::{warning}
        This opens the firewall on all network interfaces.
        :::
      '';
      type = lib.types.bool;
      default = false;
    };

    allowPVABroadcastDiscovery = lib.mkOption {
      description = ''
        This option allows the broadcast discovery of pvAccess IOCs on the default port.

        :::{danger}
        This option is a security issue
        and attackers crafting a malicious packet from source port 5076
        will be able to access any [Ephemeral port]
        of this machine.
        :::

        :::{important}
        This option currently only work with PVXS IOCs,
        and doesn't work with epics-base's pvAccess.
        :::

        :::{warning}
        This opens the firewall on all network interfaces.
        :::

          [Ephemeral port]: https://en.wikipedia.org/wiki/Ephemeral_port
      '';
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
        allowedTCPPorts = [ 5075 ];
        allowedUDPPorts = [ 5076 ];
      })
      (lib.mkIf cfg.allowCABroadcastDiscovery {
        extraCommands = ''
          ip46tables -A nixos-fw -p udp --sport 5064 --dport 32768:60999 -j nixos-fw-accept
        '';
      })
      (lib.mkIf cfg.allowPVABroadcastDiscovery {
        extraCommands = ''
          ip46tables -A nixos-fw -p udp --sport 5076 --dport 32768:60999 -j nixos-fw-accept
        '';
      })
    ];
  };
}
