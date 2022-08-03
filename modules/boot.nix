{
  config,
  lib,
  pkgs,
  epnix,
  ...
}:
with lib; let
  cfg = config.epnix.boot;
in {
  options.epnix.boot = {
    iocBoots = mkOption {
      default = [];
      type = with types; listOf (oneOf [str path package]);
      description = ''
        Additional iocBoot directories to include in this EPICS distribution.

        Note that the iocBoot directory is already included by default.

        This option support the same types of arguments as
        `epnix.support.modules`. Please refer to its documentation for more
        information.
      '';
    };

    resolvedIocBoots = mkOption {
      type = with types; listOf (either path package);
      internal = true;
      readOnly = true;
      description = ''
        Like `iocBoots`, but with the string values resolved as packages.
      '';
    };
  };

  config.epnix.boot.resolvedIocBoots = let
    available = {inputs = config.epnix.inputs;};
  in
    map (epnix.lib.resolveInput available) cfg.iocBoots;
}
