{
  stdenv,
  cmake,
  epnix,
  fetchzip,
  gtest,
}:
stdenv.mkDerivation {
  pname = "oac-tree-mathexpr";
  version = "0.0.0-spring-2025-harwell";

  src = fetchzip {
    url = "https://github.com/epics-training/oac-tree-zips/raw/95045a9ac0deec83b06628068e8ef7c08ea34419/oac-tree-mathexpr.zip";
    hash = "sha256-JLmFxaJZAEjow2ePjFisaurPkTGjTEI+Ol164TJlrrs=";
  };

  nativeBuildInputs = [cmake];
  buildInputs = with (epnix.oac-tree); [
    gtest
    sup-utils
    sup-dto
    sup-mathexpr
    oac-tree
  ];

  doCheck = true;
}
