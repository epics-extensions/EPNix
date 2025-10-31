{
  stdenv,
  cmake,
  epnix,
  fetchFromGitHub,
  gtest,
  qt6,
  libxml2,
}:
stdenv.mkDerivation (self: {
  pname = "sup-gui-core";
  version = "2.0";

  src = fetchFromGitHub {
    owner = "oac-tree";
    repo = self.pname;
    rev = "v${self.version}";
    hash = "sha256-l3X5yTT7QK3rkQ3wQuDcukOuvVhAfL0JTqAfahPSnwE=";
  };

  nativeBuildInputs = [cmake];
  buildInputs = with (epnix.oac-tree); [gtest qt6.full sup-mvvm sup-gui-extra sup-dto libxml2];
})
