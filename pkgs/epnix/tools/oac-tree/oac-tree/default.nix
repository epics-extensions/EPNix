{
  stdenv,
  epnix,
  cmake,
  fetchFromGitHub,
  gtest,
}:
stdenv.mkDerivation (self: {
  pname = "oac-tree";
  version = "4.1";

  src = fetchFromGitHub {
    owner = "oac-tree";
    repo = self.pname;
    rev = "v${self.version}";
    hash = "sha256-BecUdMhowwR/8X+o7afcl38WfCep2cllKV5bzw9mwgs=";
  };

  nativeBuildInputs = [cmake];
  buildInputs = with (epnix.oac-tree); [sup-dto sup-utils gtest];

  cmakeFlags = ["-DCOA_NO_CODAC:bool=true"];

  # Tests are very flaky, so disabled for now.
  doCheck = false;
})
