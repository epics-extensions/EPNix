{
  stdenv,
  cmake,
  epnix,
  fetchFromGitHub,
  gtest,
}:
stdenv.mkDerivation (self: {
  pname = "sup-di";
  version = "1.7";

  src = fetchFromGitHub {
    owner = "oac-tree";
    repo = self.pname;
    rev = "v${self.version}";
    hash = "sha256-DUQga66KrR68p0iMLR67DN8e5qG0gUGF0iTtD3eru2s=";
  };

  nativeBuildInputs = [cmake];
  buildInputs = [
    gtest
    epnix.oac-tree.sup-utils
  ];

  doCheck = true;
})
