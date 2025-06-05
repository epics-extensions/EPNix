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
  version = "1.8";

  src = fetchFromGitHub {
    owner = "oac-tree";
    repo = self.pname;
    rev = "v${self.version}";
    hash = "sha256-cfoY8HbTwGWIeMhz8LPZLvyXxQmzBSShJgKdlAtUFtY=";
  };

  nativeBuildInputs = [cmake];
  buildInputs = [gtest qt6.full];

  doCheck = true;
})
