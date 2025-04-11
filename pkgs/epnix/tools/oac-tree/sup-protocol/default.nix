{
  stdenv,
  cmake,
  epnix,
  fetchzip,
  gtest,
}:
stdenv.mkDerivation {
  pname = "sup-protocol";
  version = "0.0.0-spring-2025-harwell";

  src = fetchzip {
    url = "https://github.com/epics-training/oac-tree-zips/raw/95045a9ac0deec83b06628068e8ef7c08ea34419/sup-protocol.zip";
    hash = "sha256-e0da1VgUF3jWuxmINYrpa9msQtw3R71YDYyHpjANSkU=";
  };

  nativeBuildInputs = [cmake];
  buildInputs = with (epnix.oac-tree); [
    gtest
    sup-dto
    sup-utils
    sup-di
  ];

  doCheck = true;
}
