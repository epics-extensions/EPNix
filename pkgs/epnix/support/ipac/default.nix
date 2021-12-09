{ lib
, epnixLib
, mkEpicsPackage
, fetchFromGitHub
, version ? "2.16"
, sha256 ? ""
, local_config_site ? { }
, local_release ? { }
}:

let
  versions = lib.importJSON ./versions.json;
  hash = if sha256 != "" then sha256 else versions.${version}.sha256;
in
mkEpicsPackage rec {
  pname = "ipac";
  version = "2.16";
  varname = "IPAC";

  inherit local_config_site local_release;

  src = fetchFromGitHub {
    owner = "epics-modules";
    repo = "ipac";
    rev = version;
    sha256 = "sha256-J39oJ6taVpXlDlPB2tMlAZfpXqIyNzK8hhN9ndvDIbE=";
  };

  meta = {
    description = "IPAC Carrier and Communication Module Drivers";
    homepage = "https://github.com/epics-modules/ipac/wiki";
    license = lib.licenses.lgpl21Plus;
    maintainers = with epnixLib.maintainers; [ minijackson ];
  };
}
