{
  stdenv,
  cmake,
  fetchFromGitHub,
  gtest,
}:
stdenv.mkDerivation (self: {
  pname = "sup-dto";
  version = "1.7";

  src = fetchFromGitHub {
    owner = "oac-tree";
    repo = self.pname;
    rev = "v${self.version}";
    hash = "sha256-2rtMwZY4fAKfAtvw6N2hKK8OrZrYO0kGIbRqG1snSpE=";
  };

  nativeBuildInputs = [cmake];
  buildInputs = [gtest];

  doCheck = true;
})
