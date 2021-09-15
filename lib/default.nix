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
}
