{pkgs, ...}: {
  epnix = {
    meta.name = "channel-finder-test-ioc";
    buildConfig.src = ./ioc;

    support.modules = [pkgs.epnix.support.reccaster];

    nixos.services.ioc = {
      app = "simple";
      ioc = "iocSimple";
    };
  };
}
