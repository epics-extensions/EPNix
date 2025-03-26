{
  mkEpicsPackage,
  epnix,
  runCommand,
  releaseBranch,
}: let
  epics-base = epnix."epics-base${releaseBranch}";
in
  mkEpicsPackage {
    pname = "checks-default-ioc";
    version = "0.0.1";
    varname = "CHECKS_DEFAULT_IOC";

    inherit epics-base;

    src =
      runCommand "default-top" {
        nativeBuildInputs = [epics-base];
      } ''
        mkdir $out
        cd $out
        makeBaseApp.pl -u epnix -t ioc simple
        makeBaseApp.pl -u epnix -t ioc -i -a linux-x86_64 -p simple Simple
      '';

    patches = [
      ./default-top-${releaseBranch}.patch
    ];

    postPatch = ''
      cp ${./simple.db} simpleApp/Db/simple.db
      chmod +x iocBoot/iocSimple/st.cmd
    '';
  }
