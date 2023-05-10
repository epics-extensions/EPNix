# TODO: document every function
{
  inputs,
  lib,
  ...
} @ args:
with lib; let
  self = {
    documentation = import ./documentation.nix args;
    formats = import ./formats.nix args;
    licenses = import ./licenses.nix args;
    maintainers = import ./maintainers/maintainer-list.nix;

    evalEpnixModules = {
      nixpkgsConfig,
      epnixConfig,
    }: let
      nixpkgsConfigWithDefaults =
        {
          crossSystem = null;
          config = {};
        }
        // nixpkgsConfig;
      eval = evalModules {
        modules = [
          ({config, ...}: {
            config._module.args = let
              # Configure the available packages with e.g. cross compilation
              # and overlays
              finalPkgs = import inputs.nixpkgs {
                inherit (nixpkgsConfigWithDefaults) system crossSystem config;
                inherit (config.nixpkgs) overlays;
              };
            in {
              # See: https://github.com/NixOS/nixpkgs/pull/190358
              pkgs = finalPkgs.__splicedPackages;
            };
          })

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
        if failedAssertions != []
        then throw "\nFailed assertions:\n${lib.concatStringsSep "\n" (map (x: "- ${x}") failedAssertions)}"
        else lib.showWarnings eval.config.warnings eval.config;
    in {
      inherit (eval) options;
      inherit config;

      inherit (config.epnix) outputs;
    };

    mkEpnixBuild = cfg:
      (self.evalEpnixModules cfg).config.epnix.outputs.build;

    mkEpnixDevShell = cfg:
      (self.evalEpnixModules cfg).config.epnix.outputs.devShell;

    mkEpnixManPage = cfg:
      (self.evalEpnixModules cfg).config.epnix.outputs.manpage;

    # Like lib.getName, but also supports paths
    getName = thing:
      if builtins.isPath thing
      then baseNameOf thing
      else lib.getName thing;

    toEpicsArch = system: let
      inherit (system) parsed;

      kernel =
        {
          darwin = "darwin";
          macos = "darwin";

          freebsd = "freebsd";
          # TODO: is this correct?
          netbsd = "freebsd";
          openbsd = "freebsd";

          ios = "ios";

          linux = "linux";

          solaris = "solaris";

          win32 =
            if parsed.abi.name == "cygnus"
            then "cygwin"
            else "win32";
          windows =
            if parsed.abi.name == "cygnus"
            then "cygwin"
            else if arch == "x86"
            then "win32"
            else if arch == "x64"
            then "windows"
            else (throw "Unsupported architecture for windows: ${arch}");
        }
        .${parsed.kernel.name}
        or (throw "Unsupported kernel type: ${parsed.kernel.name}");

      arch =
        {
          x86 =
            if parsed.cpu.bits == 64
            then
              if parsed.kernel.name == "windows"
              then "x64"
              else "x86_64"
            else "x86";

          arm =
            if parsed.cpu.bits == 64
            then "aarch64"
            else "arm";

          power =
            if parsed.cpu.bits == 64
            then "ppc64"
            else "ppc";

          sparc = "sparc";
        }
        .${parsed.cpu.family}
        or (throw "Unsupported architecture: ${parsed.cpu.name}");
    in "${kernel}-${arch}";

    resolveInput = {inputs} @ available: input:
      if isDerivation input
      then input
      else if hasPrefix "/" input
      then input
      else let
        path = splitString "." input;
      in
        {pname = last path;} // getAttrFromPath path available;
  };
in
  self
