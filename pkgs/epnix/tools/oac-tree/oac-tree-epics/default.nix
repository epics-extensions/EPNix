{
  stdenv,
  epnix,
  cmake,
  fetchFromGitHub,
  gtest,
}:
stdenv.mkDerivation (self: {
  pname = "oac-tree-epics";
  version = "4.1";

  src = fetchFromGitHub {
    owner = "oac-tree";
    repo = self.pname;
    rev = "v${self.version}";
    hash = "sha256-NEcAuPSeg2ZYdYOAjzXFHm3X2bwa0/B5OlFcYUjOsDs=";
  };

  nativeBuildInputs = [cmake];
  buildInputs = with (epnix.oac-tree); [
    gtest
    sup-dto
    sup-utils
    sup-protocol
    sup-epics
    sup-di
    oac-tree
  ];
})
