{
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  local_config_site ? {},
  local_release ? {},
}:
mkEpicsPackage rec {
  pname = "RecCaster";
  version = "1.6";
  varname = "RECCASTER";

  inherit local_config_site local_release;

  src = fetchFromGitHub {
    owner = "ChannelFinder";
    repo = "recsync";
    rev = "refs/tags/${version}";
    hash = "sha256-9ApS4e1+oDgZfx7njOuGhezr4ekP2ekJVCc7yiTXRKo=";
  };

  sourceRoot = "${src.name}/client";

  patches = [./fix-example-shebang.patch];

  postInstall = ''
    cp -rafv iocBoot -t "$out"
  '';

  meta = {
    description = "Informs ChannelFinder of the state of the IOC and the list of PVs contained in that IOC";
    homepage = "https://channelfinder.readthedocs.io/en/latest/";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [minijackson];
  };
}
