{
  mkEpicsPackage,
  epnix,
  epnixLib,
}:
mkEpicsPackage {
  pname = "exampleIoc";
  version = epnixLib.versions.current;
  varname = "EXAMPLE_IOC";

  src = ./ioc;

  propagatedBuildInputs = [
    epnix.support.reccaster
  ];

  meta.description = "Example IOC for the Phoebus ecosystem image";
}
