{pkgs, ...}: {
  epnix = {
    meta.name = "checks-support-StreamDevice-simple";
    buildConfig.src = ./.;

    applications.apps = [./simpleApp];
    boot.iocBoots = [./iocBoot/iocsimple];
    support.modules = with pkgs.epnix.support; [StreamDevice epics-systemd];

    nixos.service.app = "simple";
    nixos.service.ioc = "iocsimple";
  };
}
