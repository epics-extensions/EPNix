# TODO: document every function
{
  inputs,
  lib,
  ...
} @ args:
with lib; let
  self = {
    inherit inputs;

    ci = import ./ci.nix args;
    documentation = import ./documentation.nix args;
    evaluation = import ./evaluation.nix args;
    formats = import ./formats.nix args;
    licenses = import ./licenses.nix args;
    maintainers = import ./maintainers/maintainer-list.nix;
    testing = import ./testing.nix;
    versions = import ./versions.nix;

    inherit (self.evaluation) evalEpnixModules mkEpnixBuild mkEpnixDevShell;

    # The epnix nixosModules.nixos flake output,
    # re-exposed in epnixLib,
    # in case you're not in flake.nix.
    nixosModule = self.inputs.self.nixosModules.nixos;

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
        .${
          parsed.kernel.name
        }
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
        .${
          parsed.cpu.family
        }
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
