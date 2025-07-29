{
  inputs,
  lib,
  ...
}:
let
  evalEpnixModules' =
    {
      epnixConfig,
      epnixFunEval,
      pkgs,
    }:
    let
      eval = lib.evalModules {
        modules = [
          (
            { config, ... }:
            {
              config._module.args = {
                pkgs = pkgs config;

                # Used when we want to apply the same config in checks
                inherit epnixConfig;
                inherit epnixFunEval;
              };
            }
          )

          epnixConfig
          inputs.self.nixosModules.ioc

          # nixpkgs and assertions are separate, in case we want to include
          # this module in a NixOS configuration, where `nixpkgs` and
          # `assertions` options are already defined
          ../ioc/modules/nixpkgs.nix
          ../ioc/modules/assertions.nix
        ];
      };

      # From Robotnix
      # From nixpkgs/nixos/modules/system/activation/top-level.nix
      failedAssertions = map (x: x.message) (lib.filter (x: !x.assertion) eval.config.assertions);

      config =
        if failedAssertions != [ ] then
          throw "\nFailed assertions:\n${lib.concatStringsSep "\n" (map (x: "- ${x}") failedAssertions)}"
        else
          lib.showWarnings eval.config.warnings eval.config;
    in
    {
      inherit (eval) options;
      inherit config;

      inherit (config.epnix) outputs generatedOverlay;
    };

  self = {
    evalEpnixModules =
      {
        nixpkgsConfig,
        epnixConfig,
      }:
      let
        nixpkgsConfigWithDefaults = {
          crossSystem = null;
          config = { };
        }
        // nixpkgsConfig;

        pkgs =
          config:
          (import inputs.nixpkgs {
            inherit (nixpkgsConfigWithDefaults) system crossSystem config;
            inherit (config.nixpkgs) overlays;
          })
          # See: https://github.com/NixOS/nixpkgs/pull/190358
          .__splicedPackages;

        # As a function,
        # so that we can import the package without fixing the dependencies.
        #
        # This is needed because,
        # if this package is an EPICS support module,
        # it needs to *not* depend on a specific version of epics-base.
        #
        # It needs to use the same version of epics-base
        # that is going to be used by the final IOC.
        epnixFunEval =
          pkgs:
          evalEpnixModules' {
            inherit epnixConfig epnixFunEval;
            pkgs = config: pkgs;
          };

        fixedEval = evalEpnixModules' { inherit epnixConfig epnixFunEval pkgs; };
      in
      fixedEval;

    mkEpnixBuild = cfg: (self.evalEpnixModules cfg).config.epnix.outputs.build;

    mkEpnixDevShell = cfg: (self.evalEpnixModules cfg).config.epnix.outputs.devShell;
  };
in
self
