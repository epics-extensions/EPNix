{
  stdenv,
  lib,
  cmake,
  epnix,
  fetchzip,
  gtest,
  qt6,
  libxml2,
  patchelf,
}: let
  rpath = lib.concatStringsSep ":" [
    "${epnix.support.pvxs}/lib/linux-x86_64"
    "${epnix.epics-base}/lib/linux-x86_64"
  ];
in
  stdenv.mkDerivation {
    pname = "oac-tree-gui-unwrapped";
    version = "0.0.0-spring-2025-harwell";

    src = fetchzip {
      url = "https://github.com/epics-training/oac-tree-zips/raw/95045a9ac0deec83b06628068e8ef7c08ea34419/oac-tree-gui.zip";
      hash = "sha256-riZw9xmCNLZn6+7JL4Wa8yysxrA12rAY7UVnvSz5RYA=";
    };

    nativeBuildInputs = [
      cmake
    ];
    buildInputs = with (epnix.oac-tree); [
      gtest
      qt6.full
      libxml2

      oac-tree
      oac-tree-server
      sup-di
      sup-dto
      sup-epics
      sup-gui-core
      sup-gui-extra
      sup-mvvm
      sup-protocol
      sup-utils
    ];

    postFixup = ''
      patchelf --add-rpath "${rpath}" $out/bin/oac-tree-gui
      patchelf --add-rpath "${rpath}" $out/bin/sup-pvmonitor
      patchelf --add-rpath "${rpath}" $out/bin/oac-tree-operation
    '';
  }
