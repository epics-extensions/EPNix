{
  stdenv,
  cmake,
  fetchzip,
  gtest,
  qt6,
  libxml2,
}:
stdenv.mkDerivation {
  pname = "sup-mvvm";
  version = "0.0.0-spring-2025-harwell";

  src = fetchzip {
    url = "https://github.com/epics-training/oac-tree-zips/raw/95045a9ac0deec83b06628068e8ef7c08ea34419/sup-mvvm.zip";
    hash = "sha256-LZulP8kuMbQRsfSOmRw5KZvtZZ1cCqwvNnsqW0LD7KQ=";
  };

  nativeBuildInputs = [cmake];
  buildInputs = [gtest qt6.full libxml2];
}
