{pkgs, ...}: {
  epnix = {
    meta.name = "checks-support-autosave-simple";
    buildConfig.src = ./.;

    support.modules = with pkgs.epnix.support; [autosave];

    nixos.service.app = "simple";
    nixos.service.ioc = "iocSimple";
  };
}
