{
  stdenv,
  epnix,
  cmake,
  fetchzip,
  gtest,
}:
stdenv.mkDerivation {
  pname = "oac-tree";
  version = "0.0.0-spring-2025-harwell";

  src = fetchzip {
    url = "https://github.com/epics-training/oac-tree-zips/raw/941d0b1fc6c43ac0259610b655af212e1ccec41e/oac-tree.zip";
    hash = "sha256-R2UwTtKObfptdchcU+7sGyPQQaG+MxTS4yUEQ/0qfzo=";
  };

  nativeBuildInputs = [cmake];
  buildInputs = with (epnix.oac-tree); [sup-dto sup-utils gtest];

  cmakeFlags = ["-DCOA_NO_CODAC:bool=true"];

  doCheck = true;
}
