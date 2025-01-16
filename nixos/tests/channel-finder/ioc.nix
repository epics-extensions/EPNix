{
  mkEpicsPackage,
  epnix,
}:
mkEpicsPackage {
  pname = "channel-finder-test-ioc";
  version = "0.0.1";
  varname = "CHANNEL_FINDER_TEST_IOC";

  src = ./ioc;

  propagatedBuildInputs = [epnix.support.reccaster];
}
