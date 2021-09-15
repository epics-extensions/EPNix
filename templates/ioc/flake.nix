{
  description = "EPICS IOC for <...>";

  inputs.nixpkgs = {
    url = "github:NixOS/nixpkgs/nixos-21.05";
    follows = "epnix/nixpkgs";
  };
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.epnix.url = "/home/minijackson/Documents/Dev/nix/epnix";

  outputs = { self, nixpkgs, flake-utils, epnix }:
    let
      myEpnixDistribution = system:
        epnix.epnixDistribution.${system} ({ pkgs, epnixLib, ... }: {
          imports = [ (epnixLib.importTOML ./epnix.toml) ];

          # Add one of the supported modules through its own option:
          #epnix.support.StreamDevice.enable = true;

          # Or by specfying it here:
          #epnix.support.modules = [ pkgs.epics.support.calc ];

          # Add your applications:
          #epnix.applications.apps = [ ./myProjectApp ];

          # And your iocBoot directories:
          #epnix.boot.iocBoots = [ ./iocBoot/iocmyProject ];
        });
    in
    # Add your supported systems here.
    # "x86_64-linux" should still be specified so that the development
    # environment can be built on your machine.
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      {
        packages = (myEpnixDistribution system).outputs;

        defaultPackage = self.packages.${system}.build;
        devShell = self.packages.${system}.devShell;
      });
}
