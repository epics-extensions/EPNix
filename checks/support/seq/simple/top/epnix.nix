{pkgs, ...}: {
  epnix = {
    meta.name = "checks-support-seq-simple";
    buildConfig.src = ./.;

    support.modules = with pkgs.epnix.support; [seq];

    nixos.service.app = "simple";
    nixos.service.ioc = "iocsimple";
  };
}
