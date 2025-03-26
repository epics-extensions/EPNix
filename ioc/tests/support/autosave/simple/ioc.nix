{
  mkEpicsPackage,
  epnix,
}:
mkEpicsPackage {
  pname = "checks-support-autosave-simple";
  version = "0.0.1";
  varname = "CHECKS_SUPPORT_AUTOSAVE_SIMPLE";

  src = ./autosaveSimpleTestTop;

  propagatedBuildInputs = [epnix.support.autosave];
}
