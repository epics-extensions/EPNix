{
  stdenv,
  cmake,
  epnix,
  fetchFromGitHub,
  gtest,
}:
stdenv.mkDerivation (self: {
  pname = "sup-mathexpr";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "oac-tree";
    repo = self.pname;
    rev = "v${self.version}";
    hash = "sha256-12Zq2Coauq22BpsQ4eGTIsFIgWjPvAfpzsvoHEmz8fs=";
  };

  nativeBuildInputs = [cmake];
  buildInputs = [
    gtest
    epnix.oac-tree.sup-utils
  ];

  doCheck = true;
})
