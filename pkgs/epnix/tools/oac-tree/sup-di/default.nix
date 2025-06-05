{
  stdenv,
  cmake,
  epnix,
  fetchFromGitHub,
  gtest,
}:
stdenv.mkDerivation (self: {
  pname = "sup-di";
  version = "1.5";

  src = fetchFromGitHub {
    owner = "oac-tree";
    repo = self.pname;
    rev = "v${self.version}";
    hash = "sha256-YEhs28lcytsBAcITxoOkKrrcnISITCPcChP/dHdEOY0=";
  };

  nativeBuildInputs = [cmake];
  buildInputs = [
    gtest
    epnix.oac-tree.sup-utils
  ];

  doCheck = true;
})
