{ config, lib, pkgs, epnixLib, ... }:

with lib;
let
  cfg = config.epnix.support;
in
{
  # TODO: rename ? not really support
  options.epnix.support = {
    modules = mkOption {
      default = [ ];
      type = with types; listOf (oneOf [ str path package ]);
      description = ''
        Support modules needed for this EPICS distribution.

        If specified as a string, the string is resolved from the available
        inputs, or available packages.

        For example:

        ```nix
        { epnix.support.modules = [ "inputs.myExampleSup" ]; }
        ```

        or in TOML format:

        ```toml
        [epnix.support]
        modules = [ "inputs.myExampleSup" ]
        ```

        will refer to the `myExampleSup` input of your flake.

        Another example

        ```nix
        { epnix.support.modules = [ "pkgs.epnix.support.calc" ]; }
        ```

        or in TOML format:

        ```toml
        [epnix.support]
        modules = [ "pkgs.epnix.support.calc" ]
        ```
        
        will pick up `epnix.support.calc` from the list of available packages.
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

  config.epnix.support.resolvedModules =
    let available = {
      inputs = config.epnix.inputs;
      pkgs = pkgs;
    };
    in
    map (epnixLib.resolveInput available) cfg.modules;

  config.devShell.devshell.startup = listToAttrs
    (map
      (module: nameValuePair "epnix/${module.pname}" {
        text = ''
          source "${module}/nix-support/setup-hook"
        '';
      })
      cfg.resolvedModules);
}
