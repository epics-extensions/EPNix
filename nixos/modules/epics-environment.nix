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
  };

  config = lib.mkIf cfg.enable {
    environment.sessionVariables = {
      EPICS_CA_AUTO_ADDR_LIST = if cfg.ca_auto_addr_list then "YES" else "NO";
      EPICS_CA_ADDR_LIST = lib.concatStringsSep " " cfg.ca_addr_list;
    };
  };
}
