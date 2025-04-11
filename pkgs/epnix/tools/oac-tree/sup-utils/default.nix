{
  stdenv,
  cmake,
  fetchzip,
  gtest,
  libxml2,
}:
stdenv.mkDerivation {
  pname = "sup-utils";
  version = "0.0.0-spring-2025-harwell";

  src = fetchzip {
    url = "https://github.com/epics-training/oac-tree-zips/raw/95045a9ac0deec83b06628068e8ef7c08ea34419/sup-utils.zip";
    hash = "sha256-tgsv33IupAbizbB2ybG0+M6XE9NZU58BAgrrCcoGBxs=";
  };

  nativeBuildInputs = [cmake];
  buildInputs = [
    gtest
    libxml2
  ];

  doCheck = true;
}
