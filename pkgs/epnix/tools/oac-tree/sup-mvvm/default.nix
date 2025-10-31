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
  version = "2.0";

  src = fetchFromGitHub {
    owner = "oac-tree";
    repo = self.pname;
    rev = "v${self.version}";
    hash = "sha256-p8NeTUHpHYpWBWpC2hMJ9cw4bqkd+CcirXe4gmakX6Y=";
  };

  nativeBuildInputs = [cmake];
  buildInputs = [gtest qt6.full libxml2];
})
