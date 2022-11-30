{pkgs, ...}: {
  epnix = {
    meta.name = "checks-support-seq-simple";
    buildConfig.src = ./.;

    applications.apps = [./simpleApp];
    boot.iocBoots = [./iocBoot/iocsimple];
    support.modules = with pkgs.epnix.support; [seq];

    nixos.service.app = "simple";
    nixos.service.ioc = "iocsimple";
  };
}
