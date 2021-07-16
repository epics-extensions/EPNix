{ lib, pkgs, ... }:

with lib;
{
  make = {}: {
    type = with types; attrsOf (nullOr str);
    generate = name: value:
      pkgs.runCommand name
        {
          nativeBuildInputs = [ pkgs.gnumake ];
          value = generators.toKeyValue
            {
              mkKeyValue = k: v:
                if v == null then "undefine ${k}"
                else generators.mkKeyValueDefault { } "=" k v;
            }
            value;
          passAsFile = [ "value" ];
        } ''
        cp "$valuePath" "$out"
        make -q -E "all:" -f "$out"
      '';
  };
}
