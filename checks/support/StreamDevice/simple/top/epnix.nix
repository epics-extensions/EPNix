{ pkgs, ... }:

{
  epnix = {
    buildConfig = {
      flavor = "checks-support-StreamDevice-simple";
      src = ./.;
    };

    applications.apps = [ ./simpleApp ];
    boot.iocBoots = [ ./iocBoot/iocsimple ];
    support.modules = with pkgs.epnix.support; [ StreamDevice epics-systemd ];
  };
}
