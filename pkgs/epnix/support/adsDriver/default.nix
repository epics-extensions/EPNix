{
  mkEpicsPackage,
  fetchFromGitHub,
  epnix,
  boost,
  epnixLib,
  lib,
}:
mkEpicsPackage rec {
  pname = "adsDriver";
  version = "3.1.0";

  varname = "ADS_DRIVER";

  src = fetchFromGitHub {
    owner = "Cosylab";
    repo = pname;
    rev = "v${version}";
    fetchSubmodules = true;
    hash = "sha256-Ruzi+H8MmIgv23pzFXZlvkk3HtbDzQ9LTTVzmeGWrSI==";
  };

  nativeBuildInputs = [boost];
  buildInputs = [boost];
  propagatedBuildInputs = with epnix.support; [
    asyn
    autoparamDriver
  ];

  meta = {
    description = "EPICS support module for integrating Beckhoff PLC using the ADS protocol";
    homepage = "https://epics.cosylab.com/documentation/adsDriver/";
    license = lib.licenses.mit;
    maintainers = with epnixLib.maintainers; [synthetica];
  };
}
