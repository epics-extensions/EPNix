{
  stdenv,
  cmake,
  epnix,
  fetchzip,
  gtest,
}:
stdenv.mkDerivation {
  pname = "sup-di";
  version = "0.0.0-spring-2025-harwell";

  src = fetchzip {
    url = "https://github.com/epics-training/oac-tree-zips/raw/95045a9ac0deec83b06628068e8ef7c08ea34419/sup-di.zip";
    hash = "sha256-jlY2NiX2pj3p+/xCK8jT0XgftlsFK8F/tr9/vbC0PoE=";
  };

  nativeBuildInputs = [cmake];
  buildInputs = [
    gtest
    epnix.oac-tree.sup-utils
  ];

  doCheck = true;
}
