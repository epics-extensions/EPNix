{
  config,
  epnix,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.epnix.applications;
in {
  options.epnix.applications = {
    apps = mkOption {
      default = [];
      type = with types; listOf (oneOf [str path package]);
      description = ''
        Applications to include in this EPICS distribution

        If specified as a string, the string is resolved from the available
        inputs.

        For example:

        ```nix
        epnix.applications.apps = [ "inputs.myExampleApp" ];
        ```

        will refer to the `myExampleApp` input of your flake.

        Note that due to EPICS conventions, your application names *must* end
        with `App`.
      '';
    };

    resolvedApps = mkOption {
      type = with types; listOf (either path package);
      internal = true;
      readOnly = true;
      description = ''
        Like `apps`, but with the string values resolved as packages.
      '';
    };
  };

  config.epnix.applications.resolvedApps = let
    available = {inputs = config.epnix.inputs;};
  in
    map (epnix.lib.resolveInput available) cfg.apps;
}
