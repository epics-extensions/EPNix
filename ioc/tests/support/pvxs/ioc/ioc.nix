{
  mkEpicsPackage,
  epnix,
}:
mkEpicsPackage {
  pname = "checks-support-pvxs-ioc";
  version = "0.0.1";
  varname = "CHECKS_SUPPORT_PVXS_IOC";

  src = ./pvxsIocTestTop;

  propagatedBuildInputs = [epnix.support.pvxs];
}
