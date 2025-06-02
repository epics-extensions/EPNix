{
  stdenv,
  cmake,
  epnix,
  fetchFromGitHub,
  gtest,
  qt6,
  libxml2,
}:
stdenv.mkDerivation (self: {
  pname = "sup-gui-core";
  version = "1.8";

  src = fetchFromGitHub {
    owner = "oac-tree";
    repo = self.pname;
    rev = "v${self.version}";
    hash = "sha256-fY4bR+sPDqUeqJaLM/oVWtR6vS2sPnl/+ZpToL6+HCw=";
  };

  nativeBuildInputs = [cmake];
  buildInputs = with (epnix.oac-tree); [gtest qt6.full sup-mvvm sup-gui-extra sup-dto libxml2];
})
