{pkgs, ...}: {
  epnix = {
    meta.name = "checks-support-pvxs-qsrv2";
    buildConfig.src = ./.;

    support.modules = with pkgs.epnix.support; [pvxs];

    nixos.services.ioc = {
      app = "simple";
      ioc = "iocSimple";
    };
  };
}
