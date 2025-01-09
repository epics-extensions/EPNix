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
    hash = "sha256-p9H6nK+iYJ5ML4x3wE0CmTq0sRFS4kGNgsyKEZPb2bU=";
  };

  dontConfigure = true;

  nativeBuildInputs = [setuptools_dso epicscorelibs];

  inherit (epnix.support.pvxs) meta;
}
