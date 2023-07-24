releaseBranch: _: {
  epnix = {
    meta.name = "checks-default-ioc";
    buildConfig.src = ./.;

    epics-base.releaseBranch = releaseBranch;

    nixos.services.ioc = {
      app = "simple";
      ioc = "iocsimple";
    };
  };
}
