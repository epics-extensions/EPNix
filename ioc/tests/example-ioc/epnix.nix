{pkgs, ...}: {
  epnix = {
    meta.name = "checks-example-ioc";
    buildConfig.src =
      pkgs.runCommand "example-top" {
        nativeBuildInputs = [pkgs.epnix.epics-base];
      } ''
        mkdir $out
        cd $out
        makeBaseApp.pl -u epnix -t example simple
        makeBaseApp.pl -u epnix -t example -i -a linux-x86_64 -p simple Simple
      '';

    buildConfig.attrs.patches = [./example-top.patch];

    support.modules = with pkgs.epnix.support; [seq];

    nixos.services.ioc = {
      app = "simple";
      ioc = "iocSimple";
    };
  };
}
