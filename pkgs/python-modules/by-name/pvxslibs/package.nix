{
  buildPythonPackage,
  epnix,
  fetchPypi,
  setuptools_dso,
  epicscorelibs,
}:
buildPythonPackage rec {
  pname = "pvxslibs";
  inherit (epnix.support.pvxs) version;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-E2jP1SHt8Vvi+MRJHHyjiTt3cSE58ZuVeL3zmmUHSnk=";
  };

  dontConfigure = true;

  nativeBuildInputs = [
    setuptools_dso
    epicscorelibs
  ];

  inherit (epnix.support.pvxs) meta;
}
