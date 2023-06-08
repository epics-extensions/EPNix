{pkgs, ...}: {
  epnix = {
    meta.name = "checks-support-autosave-simple";
    buildConfig.src = ./.;

    support.modules = with pkgs.epnix.support; [autosave];

    nixos.services.ioc = {
      app = "simple";
      ioc = "iocSimple";
    };
  };
}
