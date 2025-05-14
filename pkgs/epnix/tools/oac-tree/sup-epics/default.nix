{
  stdenv,
  cmake,
  lib,
  epnix,
  fetchzip,
  gtest,
  libxml2,
  screen,
  which,
}:
stdenv.mkDerivation rec {
  pname = "sup-epics";
  version = "0.0.0-spring-2025-harwell";

  src = fetchzip {
    url = "https://github.com/epics-training/oac-tree-zips/raw/95045a9ac0deec83b06628068e8ef7c08ea34419/sup-epics.zip";
    hash = "sha256-tB4ErvZt8a8/IbNvHQ3h0800JsdvHghWkoQGp/lsJMo=";
  };

  # postPatch = ''
  #   # Used for tests:
  #   sed 's@/usr/bin/screen@${screen}/bin/screen@' -i src/lib/sup/epics-test/softioc_runner.cpp
  # '';

  nativeBuildInputs = [cmake];
  buildInputs = with (epnix.oac-tree); [
    gtest
    sup-dto
    sup-protocol
    sup-di
    epnix.epics-base7
    epnix.support.pvxs
  ];

  EPICS_BASE = "${epnix.epics-base7}";

  # XXX: how to do this properly?
  EPICS_HOST_ARCH = "linux-x86_64";
  PVXS_DIR = "${epnix.support.pvxs}";

  # Tests currently failing
  # doCheck = true;
  # checkInputs = [screen which];
}
