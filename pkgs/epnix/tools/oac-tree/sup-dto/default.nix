{
  stdenv,
  cmake,
  fetchFromGitHub,
  gtest,
}:
stdenv.mkDerivation (self: {
  pname = "sup-dto";
  version = "1.8";

  src = fetchFromGitHub {
    owner = "oac-tree";
    repo = self.pname;
    rev = "v${self.version}";
    hash = "sha256-rMAyEBxv+IZiGSRBxom/IfFpPbkPKXnB1ChGnuzx4Ew=";
  };

  nativeBuildInputs = [cmake];
  buildInputs = [gtest];

  doCheck = true;
})
