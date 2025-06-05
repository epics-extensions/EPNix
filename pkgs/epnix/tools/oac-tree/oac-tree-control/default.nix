{
  stdenv,
  cmake,
  epnix,
  fetchFromGitHub,
  gtest,
}:
stdenv.mkDerivation (self: {
  pname = "oac-tree-control";
  version = "2.1";

  src = fetchFromGitHub {
    owner = "oac-tree";
    repo = self.pname;
    rev = "v${self.version}";
    hash = "sha256-nTfigbvTJowCCZoLkvduWikos2mmeyuLlOMjaFD17RE=";
  };

  nativeBuildInputs = [cmake];
  buildInputs = with (epnix.oac-tree); [
    gtest
    sup-utils
    sup-dto
    oac-tree
  ];

  doCheck = true;
})
