{
  stdenv,
  cmake,
  fetchFromGitHub,
  gtest,
  libxml2,
}:
stdenv.mkDerivation (self: {
  pname = "sup-utils";
  version = "1.6";

  src = fetchFromGitHub {
    owner = "oac-tree";
    repo = self.pname;
    rev = "v${self.version}";
    hash = "sha256-OhmLlf3+yk5D2PxCCIRXm1YE4eOB91A5Og1a9Ipki48=";
  };

  nativeBuildInputs = [cmake];
  buildInputs = [
    gtest
    libxml2
  ];

  doCheck = true;
})
