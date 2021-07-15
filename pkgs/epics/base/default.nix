{ lib
, fetchgit
, rev ? "R7.0.6"
, sha256 ? ""
}:

let
  versions = lib.importJSON ./versions.json;
  hash = if sha256 != "" then sha256 else versions.${rev}.sha256;
in
fetchgit {
  url = "https://git.launchpad.net/epics-base";
  inherit rev;
  sha256 = hash;
}
