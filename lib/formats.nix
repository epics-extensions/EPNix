{ lib, ... }:

with lib;
{
  make = {}: {
    type = with types; attrsOf (nullOr str);
    generate = value:
      generators.toKeyValue
        {
          mkKeyValue = k: v:
            if v == null then "undefine ${k}"
            else generators.mkKeyValueDefault { } "=" k v;
        }
        value;
  };
}
