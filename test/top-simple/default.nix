{ lib
, mkEpicsPackage
, local_config_site ? { }
, local_release ? { }
}:

mkEpicsPackage {
  pname = "top-simple";
  version = "0.0.1";

  varname = "TOP_SIMPLE";

  inherit local_config_site local_release;

  src = ./.;
}
