{
  mkEpicsPackage,
  epnix,
  runCommand,
}:
mkEpicsPackage {
  pname = "checks-example-ioc";
  version = "0.0.1";
  varname = "CHECKS_EXAMPLE_IOC";

  src =
    runCommand "default-top" {
      nativeBuildInputs = [epnix.epics-base];
    } ''
      mkdir $out
      cd $out
      makeBaseApp.pl -u epnix -t example simple
      makeBaseApp.pl -u epnix -t example -i -a linux-x86_64 -p simple Simple
    '';

  patches = [
    ./example-top.patch
  ];

  propagatedBuildInputs = [epnix.support.seq];

  postPatch = ''
    chmod +x iocBoot/iocSimple/st.cmd
  '';
}
