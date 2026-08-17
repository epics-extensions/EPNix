{ pkgs, ... }:

{
  services.iocs.exampleIoc = {
    package = pkgs.callPackage ./ioc-package.nix { };
    workingDirectory = "iocBoot/iocExample";
  };

  environment.epics = {
    openCAFirewall = true;
    openPVAFirewall = true;
  };

  networking.firewall.allowedUDPPorts = [ 5049 ];

  environment.systemPackages = with pkgs; [ epnix.epics-base ];
}
