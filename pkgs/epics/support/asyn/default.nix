{ lib
, mkEpicsPackage
, fetchgit
, version ? "4-42"
, sha256 ? ""
, epics
, pkg-config
, rpcsvc-proto
, libtirpc
, local_config_site ? { }
, local_release ? { }
}:

let
  versions = lib.importJSON ./versions.json;
  hash = if sha256 != "" then sha256 else versions.${version}.sha256;
in
mkEpicsPackage {
  pname = "asyn";
  inherit version;
  varname = "ASYN";

  inherit local_config_site;
  local_release = local_release // {
    TIRPC = "YES";
  };

  nativeBuildInputs = [ pkg-config rpcsvc-proto ];
  buildInputs = [ libtirpc ] ++ (with epics.support; [ ipac seq ]);

  patches = [ ./use-pkg-config.patch ];

  src = fetchgit {
    url = "https://github.com/epics-modules/asyn.git";
    rev = "R${version}";
    sha256 = hash;
  };
}
