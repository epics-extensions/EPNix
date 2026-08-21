{
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
}:
mkEpicsPackage (finalAttrs: {
  pname = "RecCaster";
  version = "1.9.7";
  varname = "RECCASTER";

  src = fetchFromGitHub {
    owner = "ChannelFinder";
    repo = "reccaster";
    tag = finalAttrs.version;
    hash = "sha256-IuK65PCsxzxQxL4CJvI8WE2eOI3dHPuUfalAxS7wDTI=";
  };

  patches = [ ./fix-example-shebang.patch ];

  meta = {
    description = "Informs ChannelFinder of the state of the IOC and the list of PVs contained in that IOC";
    homepage = "https://channelfinder.readthedocs.io/en/latest/";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [ minijackson ];
  };
})
