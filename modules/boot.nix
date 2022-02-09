{ config, lib, pkgs, epnixLib, ... }:

with lib;

let
  cfg = config.epnix.boot;
in
{
  options.epnix.boot = {
    iocBoots = mkOption {
      default = [ ];
      type = with types; listOf (oneOf [ str path package ]);
      description = ''
        iocBoot modules to include in this EPICS distribution.

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

  config.epnix.boot.resolvedIocBoots =
    let available = {
      inputs = config.epnix.inputs;
      pkgs = pkgs;
    };
    in
    map (epnixLib.resolveInput available) cfg.iocBoots;
}
