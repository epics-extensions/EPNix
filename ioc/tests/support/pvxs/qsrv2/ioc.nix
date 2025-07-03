{
  mkEpicsPackage,
  pvxs,
}:
mkEpicsPackage {
  pname = "checks-support-pvxs-qsrv2";
  version = "0.0.1";
  varname = "CHECKS_SUPPORT_PVXS_QSRV2";

  src = ./pvxsQsrv2TestTop;

  propagatedBuildInputs = [ pvxs ];
}
