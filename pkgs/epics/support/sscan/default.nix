{ lib
, mkEpicsPackage
, fetchgit
, fetchpatch
, version ? "2-11-4"
, sha256 ? ""
, epics
, local_config_site ? { }
, local_release ? { }
}:

let
  versions = lib.importJSON ./versions.json;
  hash = if sha256 != "" then sha256 else versions.${version}.sha256;
in
mkEpicsPackage {
  pname = "sscan";
  inherit version;
  varname = "SSCAN";

  inherit local_config_site local_release;

  buildInputs = with epics.support; [ seq ];

  patches = [
    # Include shareLib.h, needed for recent base 7.0 where it is no longer indirectly included
    (fetchpatch {
      url = "https://github.com/epics-modules/sscan/commit/420274ca2e4331e92119bd0524d0bcd7ffdd9f93.patch";
      sha256 = "sha256-HRuxsuaodumoQ6asKDsVhYioZEeHtFvln/Oj3XDLIDA=";
    })
  ];

  src = fetchgit {
    url = "https://github.com/epics-modules/sscan.git";
    rev = "R${version}";
    sha256 = hash;
  };
}
