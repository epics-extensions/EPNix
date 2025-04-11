{
  stdenv,
  cmake,
  fetchzip,
  gtest,
}:
stdenv.mkDerivation {
  pname = "sup-dto";
  version = "0.0.0-spring-2025-harwell";

  src = fetchzip {
    url = "https://github.com/epics-training/oac-tree-zips/raw/95045a9ac0deec83b06628068e8ef7c08ea34419/sup-dto.zip";
    hash = "sha256-1xZcopgjexmZBdhKEjHtOJAU+3pKZz+xgoW6zgOc8xA=";
  };

  nativeBuildInputs = [cmake];
  buildInputs = [gtest];

  doCheck = true;
}
