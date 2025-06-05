{
  stdenv,
  cmake,
  fetchFromGitHub,
  gtest,
  qt6,
  libxml2,
}:
stdenv.mkDerivation (self: {
  pname = "sup-mvvm";
  version = "1.8";

  src = fetchFromGitHub {
    owner = "oac-tree";
    repo = self.pname;
    rev = "v${self.version}";
    hash = "sha256-/eZIGuuPKOd1LNkD2I3r040GlQUMSfZwXCepfgYTd+A=";
  };

  nativeBuildInputs = [cmake];
  buildInputs = [gtest qt6.full libxml2];
})
