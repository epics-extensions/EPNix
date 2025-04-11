{
  stdenv,
  cmake,
  epnix,
  fetchzip,
  gtest,
  qt6,
  libxml2,
}:
stdenv.mkDerivation {
  pname = "sup-gui-core";
  version = "0.0.0-spring-2025-harwell";

  src = fetchzip {
    url = "https://github.com/epics-training/oac-tree-zips/raw/95045a9ac0deec83b06628068e8ef7c08ea34419/sup-gui-core.zip";
    hash = "sha256-TuM8/BEFAcF3QhXTYK+HwVdQY+Qbpri9LfKPnQ2Us7w=";
  };

  nativeBuildInputs = [cmake];
  buildInputs = with (epnix.oac-tree); [gtest qt6.full sup-mvvm sup-gui-extra sup-dto libxml2];
}
