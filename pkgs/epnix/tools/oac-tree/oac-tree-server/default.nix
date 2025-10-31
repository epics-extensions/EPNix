{
  stdenv,
  lib,
  epnix,
  cmake,
  fetchFromGitHub,
  gtest,
}: let
  rpath = lib.concatStringsSep ":" [
    "${epnix.support.pvxs}/lib/linux-x86_64"
    "${epnix.epics-base}/lib/linux-x86_64"
  ];
in
  stdenv.mkDerivation (self: {
    pname = "oac-tree-server";
    version = "2.3";

    src = fetchFromGitHub {
      owner = "oac-tree";
      repo = self.pname;
      rev = "v${self.version}";
      hash = "sha256-0fTTsegFBrXd18YbG8O7TYcJdBeMm3x8dC/BnmdoIac=";
    };

    nativeBuildInputs = [cmake];
    buildInputs = with (epnix.oac-tree); [
      gtest
      sup-dto
      sup-utils
      sup-epics
      sup-protocol
      sup-di
      oac-tree
    ];

    postFixup = ''
      patchelf --add-rpath "${rpath}" $out/bin/oac-tree-server
    '';
  })
