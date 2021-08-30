{ lib
, mkEpicsPackage
, fetchzip
, version ? "2.2.6"
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
  pname = "seq";
  inherit version;
  varname = "SNCSEQ";

  inherit local_config_site local_release;

  nativeBuildInputs = [ re2c ];

  preBuild = ''
    echo 'include $(TOP)/configure/RELEASE.local' >> configure/RELEASE
  '';

  src = fetchzip {
    url = "https://www-csr.bessy.de/control/SoftDist/sequencer/releases/seq-${version}.tar.gz";
    sha256 = hash;
  };
}
