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

  config.epnix.support.resolvedModules =
    let available = { inputs = config.epnix.inputs; };
    in
    map (epnixLib.resolveInput available) cfg.modules;

    config.devShell.devshell.startup."epnix-startup-hooks".text = ''
      function eval_startup_hook {
        local module="$1"

        local startup_hook="''${module}/nix-support/setup-hook"

        if [[ -f  "''${startup_hook}" ]]; then
          source "''${startup_hook}"
        fi

        local propagated_build_inputs_file="''${module}/nix-support/propagated-build-inputs"

        if [[ -f "''${propagated_build_inputs_file}" ]]; then
          IFS=" " read -a propagated_build_inputs < "''${propagated_build_inputs_file}"

          for propagated_build_input in "''${propagated_build_inputs[@]}"; do
            eval_startup_hook "''${propagated_build_input}"
          done
        fi
      }

      ${concatStringsSep
        "\n"
        (map
          (module: ''eval_startup_hook "${module}"'')
          cfg.resolvedModules)}
    '';
}
