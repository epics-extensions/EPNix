{ lib
, mkEpicsPackage
, fetchFromGitHub
, version ? "2.16"
, sha256 ? ""
, re2c
, local_config_site ? { }
, local_release ? { }
}:

let
  versions = lib.importJSON ./versions.json;
  hash = if sha256 != "" then sha256 else versions.${version}.sha256;
in
mkEpicsPackage {
  pname = "ipac";
  inherit version;
  varname = "IPAC";

  inherit local_config_site local_release;

  nativeBuildInputs = [];

  src = fetchFromGitHub {
    owner = "epics-modules";
    repo = "ipac";
    rev = version;
    sha256 = hash;
  };
}
