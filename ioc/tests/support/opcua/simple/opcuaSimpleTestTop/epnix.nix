{pkgs, ...}: {
  epnix = {
    meta.name = "checks-support-snmp-simple";
    buildConfig.src = ./.;

    support.modules = with pkgs.epnix.support; [opcua];

    nixos.service.app = "simple";
    nixos.service.ioc = "iocSimple";
  };
}
