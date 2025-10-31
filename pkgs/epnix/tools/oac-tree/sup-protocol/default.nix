{
  stdenv,
  cmake,
  epnix,
  fetchFromGitHub,
  gtest,
}:
stdenv.mkDerivation (self: {
  pname = "sup-protocol";
  version = "2.6";

  src = fetchFromGitHub {
    owner = "oac-tree";
    repo = self.pname;
    rev = "v${self.version}";
    hash = "sha256-BbqJrhGBWq9y5E8KKWfch8EzyzHis8VHS9Fnqu0N5B4=";
  };

  nativeBuildInputs = [cmake];
  buildInputs = with (epnix.oac-tree); [
    gtest
    sup-dto
    sup-utils
    sup-di
  ];

  doCheck = true;
})
