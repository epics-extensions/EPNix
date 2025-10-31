{
  stdenv,
  cmake,
  epnix,
  fetchFromGitHub,
  gtest,
}:
stdenv.mkDerivation (self: {
  pname = "oac-tree-mathexpr";
  version = "2.3";

  src = fetchFromGitHub {
    owner = "oac-tree";
    repo = self.pname;
    rev = "v${self.version}";
    hash = "sha256-VMEZtjPtBI52Ts8vyw6lsLBqs1rc9DG++4Tmbcezs/w=";
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
})
