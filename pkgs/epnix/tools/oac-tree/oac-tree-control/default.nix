{
  stdenv,
  cmake,
  epnix,
  fetchzip,
  gtest,
}:
stdenv.mkDerivation {
  pname = "oac-tree-control";
  version = "0.0.0-spring-2025-harwell";

  src = fetchzip {
    url = "https://github.com/epics-training/oac-tree-zips/raw/95045a9ac0deec83b06628068e8ef7c08ea34419/oac-tree-control.zip";
    hash = "sha256-6j2jJD7OVo/N2MuK3/WxYTnXOSZoI/hOTPAwJrqL4JI=";
  };

  nativeBuildInputs = [cmake];
  buildInputs = with (epnix.oac-tree); [
    gtest
    sup-utils
    sup-dto
    oac-tree
  ];

  doCheck = true;
}
