{
  stdenv,
  cmake,
  epnix,
  fetchFromGitHub,
  gtest,
  qt6,
  # libxml2,
}:
stdenv.mkDerivation (self: {
  pname = "sup-gui-extra";
  version = "1.9";

  src = fetchFromGitHub {
    owner = "oac-tree";
    repo = self.pname;
    rev = "v${self.version}";
    hash = "sha256-6k/zVLzkn379x6Yk5qX7Fzx2y9L3dsWJwAlEcRayFA0=";
  };

  nativeBuildInputs = [cmake];
  buildInputs = [gtest qt6.full];

  doCheck = true;
})
