{
  stdenv,
  epnix,
  cmake,
  fetchFromGitHub,
  gtest,
}:
stdenv.mkDerivation (self: {
  pname = "oac-tree-epics";
  version = "4.3";

  src = fetchFromGitHub {
    owner = "oac-tree";
    repo = self.pname;
    rev = "v${self.version}";
    hash = "sha256-KuM3KF9E3GlB4p7axq4c8abRAfNl2JuaaG8r7j13XS4=";
  };

  nativeBuildInputs = [cmake];
  buildInputs = with (epnix.oac-tree); [
    gtest
    sup-dto
    sup-utils
    sup-protocol
    sup-epics
    sup-di
    oac-tree
  ];
})
