{pkgs, ...}: {
  epnix = {
    meta.name = "checks-support-StreamDevice-simple";
    buildConfig.src = ./.;

    support.modules = with pkgs.epnix.support; [StreamDevice epics-systemd];

    nixos.services.ioc = {
      app = "simple";
      ioc = "iocsimple";
    };
  };
}
