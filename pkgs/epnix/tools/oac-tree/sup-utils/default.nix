{
  stdenv,
  cmake,
  fetchFromGitHub,
  gtest,
  libxml2,
}:
stdenv.mkDerivation (self: {
  pname = "sup-utils";
  version = "1.7";

  src = fetchFromGitHub {
    owner = "oac-tree";
    repo = self.pname;
    rev = "v${self.version}";
    hash = "sha256-+MYPtwFrfCdBzX4tZg03gkWHJzJW/PuFB2X66H91IbY=";
  };

  nativeBuildInputs = [cmake];
  buildInputs = [
    gtest
    libxml2
  ];

  doCheck = true;
})
