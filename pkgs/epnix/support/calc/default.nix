{ lib
, mkEpicsPackage
, fetchgit
, version ? "3-7-4"
, sha256 ? ""
, epnix
, local_config_site ? { }
, local_release ? { }
}:

let
  versions = lib.importJSON ./versions.json;
  hash = if sha256 != "" then sha256 else versions.${version}.sha256;
in
mkEpicsPackage {
  pname = "calc";
  inherit version;
  varname = "CALC";

  inherit local_config_site local_release;

  buildInputs = with epnix.support; [ sscan ];

  src = fetchgit {
    url = "https://github.com/epics-modules/calc.git";
    rev = "R${version}";
    sha256 = hash;
  };
}
