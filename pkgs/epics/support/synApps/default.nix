{ lib
, fetchzip
, rev ? "6_1"
, sha256 ? ""
}:

let
  versions = lib.importJSON ./versions.json;
  hash = if sha256 != "" then sha256 else versions.${rev}.sha256;
in
fetchzip {
  url = "https://epics.anl.gov/bcda/synApps/tar/synApps_${rev}.tar.gz";
  sha256 = hash;
}
