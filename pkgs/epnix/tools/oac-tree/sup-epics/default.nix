{
  stdenv,
  cmake,
  lib,
  epnix,
  fetchFromGitHub,
  gtest,
  libxml2,
  screen,
  which,
}:
stdenv.mkDerivation (self: {
  pname = "sup-epics";
  version = "1.7";

  src = fetchFromGitHub {
    owner = "oac-tree";
    repo = self.pname;
    rev = "v${self.version}";
    hash = "sha256-JscVogvU2xjujGht+ORdkd0OGlsFIe+2EwyAjmecQ+o=";
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
})
