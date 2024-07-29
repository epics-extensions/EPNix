releaseBranch: {pkgs, ...}: {
  epnix = {
    meta.name = "checks-default-ioc";
    buildConfig.src =
      pkgs.runCommand "default-top" {
        nativeBuildInputs = [pkgs.epnix.epics-base];
      } ''
        mkdir $out
        cd $out
        makeBaseApp.pl -u epnix -t ioc simple
        makeBaseApp.pl -u epnix -t ioc -i -a linux-x86_64 -p simple Simple
      '';

    buildConfig.attrs = {
      patches = [./default-top-${releaseBranch}.patch];
      postPatch = ''
        cp ${./simple.db} simpleApp/Db/simple.db
      '';
    };

    epics-base.releaseBranch = releaseBranch;

    nixos.services.ioc = {
      app = "simple";
      ioc = "iocSimple";
    };
  };
}
