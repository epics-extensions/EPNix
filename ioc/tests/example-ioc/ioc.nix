{
  mkEpicsPackage,
  runCommand,
  epics-base,
  seq,
}:
mkEpicsPackage {
  pname = "checks-example-ioc";
  version = "0.0.1";
  varname = "CHECKS_EXAMPLE_IOC";

  src =
    runCommand "default-top"
      {
        nativeBuildInputs = [ epics-base ];
      }
      ''
        mkdir $out
        cd $out
        makeBaseApp.pl -u epnix -t example simple
        makeBaseApp.pl -u epnix -t example -i -a linux-x86_64 -p simple Simple
      '';

  patches = [
    ./example-top.patch
  ];

  propagatedBuildInputs = [ seq ];

  postPatch = ''
    chmod +x iocBoot/iocSimple/st.cmd
  '';
}
