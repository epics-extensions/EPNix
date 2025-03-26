{
  mkEpicsPackage,
  epnix,
}:
mkEpicsPackage {
  pname = "checks-support-pvxs-standalone-server";
  version = "0.0.1";
  varname = "CHECKS_SUPPORT_PVXS_STANDALONE_SERVER";

  src = ./pvxsStandaloneServerTestTop;

  propagatedBuildInputs = [epnix.support.pvxs];
}
