{ pkgs, ... }:

{
  epnix = {
    applications.apps = [ ./simpleApp ];
    boot.iocBoots = [ ./iocBoot/iocsimple ];
    buildConfig.flavor = "checks-support-StreamDevice-simple";
    support.modules = with pkgs.epnix.support; [ StreamDevice epics-systemd ];
  };
}
