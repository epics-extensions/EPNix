{ lib, pkgs, ... }:

with lib;
{
  make = {}: {
    type = types.attrsOf types.str;
    generate = name: value:
      pkgs.runCommand name
        {
          nativeBuildInputs = [ pkgs.gnumake ];
          value = generators.toKeyValue { } value;
          passAsFile = [ "value" ];
        } ''
        cp "$valuePath" "$out"
        make -q -E "all:" -f "$out"
      '';
  };
}
