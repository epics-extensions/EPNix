{
  config,
  lib,
  pkgs,
  epnix,
  ...
}:
with lib; let
  cfg = config.epnix.support;
in {
  options.epnix.support = {
    modules = mkOption {
      default = [];
      type = with types; listOf (oneOf [str path package]);
      description = ''
        Support modules needed for this EPICS distribution.

        Example:

        ```nix
        epnix.support.modules = with pkgs.epnix.support; [ calc ];
        ```

        If specified as a string, the string is resolved from the available
        inputs.

        For example:

        ```nix
        epnix.support.modules = [ "inputs.myExampleSup" ];
        ```

        will refer to the `myExampleSup` input of your flake.
      '';
    };

    resolvedModules = mkOption {
      type = with types; listOf (either path package);
      internal = true;
      readOnly = true;
      description = ''
        Like `modules`, but with the string values resolved as packages.
      '';
    };
  };

  config.epnix.support.resolvedModules = let
    available = {inputs = config.epnix.inputs;};
  in
    map (epnix.lib.resolveInput available) cfg.modules;
}
