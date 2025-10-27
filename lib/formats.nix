{ lib, ... }:
{
  make =
    { }:
    {
      type = with lib.types; attrsOf (nullOr str);
      generate =
        value:
        lib.generators.toKeyValue {
          mkKeyValue =
            k: v: if v == null then "undefine ${k}" else lib.generators.mkKeyValueDefault { } "=" k v;
        } value;
    };
}
