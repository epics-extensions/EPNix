{ lib
, fetchgit
, rev ? "R4-42"
, sha256 ? ""
}:

let
  versions = lib.importJSON ./versions.json;
  hash = if sha256 != "" then sha256 else versions.${rev}.sha256;
in
fetchgit {
  url = "https://github.com/epics-modules/asyn.git";
  inherit rev;
  sha256 = hash;
}
