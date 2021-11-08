{ lib, ... } @ args:

with lib;

let
  convertRelPaths = file: value:
    if isString value && hasPrefix "./" value
    then /. + (dirOf file) + "/${value}"
    else if isList value then map (convertRelPaths file) value
    else if isAttrs value then mapAttrsRecursive (_path: value: convertRelPaths file value) value
    else value;
in
{
  formats = import ./formats.nix args;

  types = import ./types.nix args;

  # Like "nixpkgs.lib.modules.importTOML, but replace any string starting with
  # "./" with an absolute path from the directory of the given file.
  importTOML = file: {
    _file = file;
    config = mapAttrsRecursive
      (_path: value: convertRelPaths file value)
      (importTOML file);
  };

  # Like lib.getName, but also supports paths
  getName = thing: if builtins.isPath thing then baseNameOf thing else lib.getName thing;

  toEpicsArch = system:
    let
      inherit (system) parsed;

      kernel = {
        darwin = "darwin";
        macos = "darwin";

        freebsd = "freebsd";
        # TODO: is this correct?
        netbsd = "freebsd";
        openbsd = "freebsd";

        ios = "ios";

        linux = "linux";

        solaris = "solaris";

        win32 = if parsed.abi.name == "cygnus" then "cygwin" else "win32";
        windows =
          if parsed.abi.name == "cygnus" then "cygwin" else
          if arch == "x86" then "win32" else
          if arch == "x64" then "windows" else
          (throw "Unsupported architecture for windows: ${arch}");

      }.${parsed.kernel.name} or (throw "Unsupported kernel type: ${parsed.kernel.name}");

      arch = {
        x86_64 = if parsed.kernel.name == "windows" then "x64" else "x86_64";
        # TODO: is this correct? EPICS' CONFIG_SITE files don't seem to
        # differenciate between i386, i486, i586, and i686
        i686 = "x86";

        powerpc = "ppc";
        powerpc64 = "ppc64";

        sparc = "sparc";
      }.${parsed.cpu.name} or (throw "Unsupported architecture: ${parsed.cpu.name}");
    in
    "${kernel}-${arch}";
}
