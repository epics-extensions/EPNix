{
  stdenv,
  cmake,
  epnix,
  fetchzip,
  gtest,
  qt6,
  # libxml2,
}:
stdenv.mkDerivation {
  pname = "sup-gui-extra";
  version = "0.0.0-spring-2025-harwell";

  src = fetchzip {
    url = "https://github.com/epics-training/oac-tree-zips/raw/95045a9ac0deec83b06628068e8ef7c08ea34419/sup-gui-extra.zip";
    hash = "sha256-03zXryquNFbHjkAVFK9WSKKDx0JqN/H66M5R3pR7d68=";
  };

  nativeBuildInputs = [cmake];
  buildInputs = [gtest qt6.full];

  doCheck = true;
}
