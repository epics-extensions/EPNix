{
  stdenv,
  lib,
  epnix,
  cmake,
  fetchzip,
  gtest,
}: let
  rpath = lib.concatStringsSep ":" [
    "${epnix.support.pvxs}/lib/linux-x86_64"
    "${epnix.epics-base}/lib/linux-x86_64"
  ];
in
  stdenv.mkDerivation {
    pname = "oac-tree-server";
    version = "0.0.0-spring-2025-harwell";

    src = fetchzip {
      url = "https://github.com/epics-training/oac-tree-zips/raw/941d0b1fc6c43ac0259610b655af212e1ccec41e/oac-tree-server.zip";
      hash = "sha256-CYKbEZViUQGWL9SaSN3HUdH5M7gkYsfH0gP0VZtttVM=";
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
  }
