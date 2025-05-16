{
  mkEpicsPackage,
  seq,
}:
mkEpicsPackage {
  pname = "checks-support-seq-simple";
  version = "0.0.1";
  varname = "CHECKS_SUPPORT_SEQ_SIMPLE";

  src = ./top;

  propagatedBuildInputs = [seq];
}
