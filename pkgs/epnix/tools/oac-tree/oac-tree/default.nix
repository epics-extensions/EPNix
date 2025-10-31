{
  stdenv,
  epnix,
  cmake,
  fetchFromGitHub,
  gtest,
}:
stdenv.mkDerivation (self: {
  pname = "oac-tree";
  version = "4.3";

  src = fetchFromGitHub {
    owner = "oac-tree";
    repo = self.pname;
    rev = "v${self.version}";
    hash = "sha256-MWOaxNnWpYt21VNMonlJXFDn7A//ItptZU+AcaU78jQ=";
  };

  nativeBuildInputs = [cmake];
  buildInputs = with (epnix.oac-tree); [sup-dto sup-utils gtest];

  cmakeFlags = ["-DCOA_NO_CODAC:bool=true"];

  # Tests are very flaky, so disabled for now.
  doCheck = false;
})
