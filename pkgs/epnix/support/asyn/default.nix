{ lib
, epnixLib
, mkEpicsPackage
, fetchgit
, version ? "4-42"
, sha256 ? ""
, epnix
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
  buildInputs = [ libtirpc ] ++ (with epnix.support; [ ipac seq ]);

  patches = [ ./use-pkg-config.patch ];

  src = fetchgit {
    url = "https://github.com/epics-modules/asyn.git";
    rev = "R${version}";
    sha256 = hash;
  };

  meta = {
    description = "EPICS module for driver and device support";
    homepage = "https://epics-modules.github.io/master/asyn/";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [ minijackson ];
  };
}
