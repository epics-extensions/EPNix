{
  stdenv,
  lib,
  cmake,
  epnix,
  fetchFromGitHub,
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
  stdenv.mkDerivation (self: {
    pname = "oac-tree-gui-unwrapped";
    version = "2.0";

    src = fetchFromGitHub {
      owner = "oac-tree";
      repo = "oac-tree-gui";
      rev = "v${self.version}";
      hash = "sha256-+k65dDbh/VczwjvLI3WSfjWW4NQwulwQDnHht45Ex64=";
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
  })
