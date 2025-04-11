{
  stdenv,
  cmake,
  epnix,
  fetchzip,
  gtest,
}:
stdenv.mkDerivation {
  pname = "sup-mathexpr";
  version = "0.0.0-spring-2025-harwell";

  src = fetchzip {
    url = "https://github.com/epics-training/oac-tree-zips/raw/95045a9ac0deec83b06628068e8ef7c08ea34419/sup-mathexpr.zip";
    hash = "sha256-HlaX1Rct5RML1o3sgYRZubFTAlzgf4pPzQlYUd5sV9k=";
  };

  nativeBuildInputs = [cmake];
  buildInputs = [
    gtest
    epnix.oac-tree.sup-utils
  ];

  doCheck = true;
}
