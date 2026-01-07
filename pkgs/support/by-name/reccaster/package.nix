{
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
}:
mkEpicsPackage rec {
  pname = "RecCaster";
  version = "1.7";
  varname = "RECCASTER";

  src = fetchFromGitHub {
    owner = "ChannelFinder";
    repo = "recsync";
    tag = version;
    hash = "sha256-IXwMEfHxzurqlfY73cAyk1PkLRQMZPhjzX+TIhZxrNU=";
  };

  sourceRoot = "${src.name}/client";

  patches = [ ./fix-example-shebang.patch ];

  meta = {
    description = "Informs ChannelFinder of the state of the IOC and the list of PVs contained in that IOC";
    homepage = "https://channelfinder.readthedocs.io/en/latest/";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [ minijackson ];
  };
}
