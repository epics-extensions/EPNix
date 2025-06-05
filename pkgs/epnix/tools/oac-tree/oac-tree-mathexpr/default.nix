{
  stdenv,
  cmake,
  epnix,
  fetchFromGitHub,
  gtest,
}:
stdenv.mkDerivation (self: {
  pname = "oac-tree-mathexpr";
  version = "2.1";

  src = fetchFromGitHub {
    owner = "oac-tree";
    repo = self.pname;
    rev = "v${self.version}";
    hash = "sha256-clymIqjXoG1UjMMlHdBmA6yjTKh/8UXQidrKzqcD3ac=";
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
