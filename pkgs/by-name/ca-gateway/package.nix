{
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  python3Packages,
  epnix,
}:
mkEpicsPackage rec {
  pname = "ca-gateway";
  version = "2.1.3";
  varname = "CA_GATEWAY";

  src = fetchFromGitHub {
    owner = "epics-extensions";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-PUe/MPvmBUFOKsrgIZvz65K1/HhD/ugmldKGY6SnMck=";
  };

  buildInputs = with epnix; [pcas];

  # Needs pyepics
  doCheck = false;
  checkInputs = [python3Packages.nose];

  meta = {
    description = "Channel Access PV gateway";
    homepage = "https://epics.anl.gov/extensions/gateway/";
    mainProgram = "gateway";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [minijackson];
  };
}
