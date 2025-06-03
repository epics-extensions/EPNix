{
  mkEpicsPackage,
  StreamDevice,
  epics-systemd,
}:
mkEpicsPackage {
  pname = "checks-support-StreamDevice-simple";
  version = "0.0.1";
  varname = "CHECKS_SUPPORT_STREAM_DEVICE_SIMPLE";

  src = ./top;

  propagatedBuildInputs = [
    StreamDevice
    epics-systemd
  ];
}
