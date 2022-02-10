{
  description = "EPICS IOC for <...>";

  inputs.nixpkgs = {
    url = "github:NixOS/nixpkgs/nixos-21.11";
    follows = "epnix/nixpkgs";
  };
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.epnix.url = "git+ssh://git@drf-gitlab.cea.fr/EPICS/epnix/epnix.git";

  # Add your app inputs here:
  # ---
  #inputs.exampleApp = {
  #  url = "git+ssh://git@my-server.org/me/exampleApp.git";
  #  flake = false;
  #};

  outputs = { self, nixpkgs, flake-utils, epnix, ... } @ inputs:
    let
      myEpnixDistribution = { pkgs, epnixLib, ... }: {
        imports = [ (epnixLib.importTOML ./epnix.toml) ];

        epnix.inputs = inputs;

        # Set your EPNix options here, or in the ./epnix.toml file
        # ---

        # Add one of the supported modules through its own option:
        #epnix.support.StreamDevice.enable = true;

        # Or by specfying it here:
        #epnix.support.modules = [ pkgs.epnix.support.calc ];

        # Add your applications:
        #epnix.applications.apps = [ "inputs.exampleApp" ];

        # And your iocBoot directories:
        #epnix.boot.iocBoots = [ ./iocBoot/iocexample ];
      };
    in
    # Add your supported systems here.
    # ---
    # "x86_64-linux" should still be specified so that the development
    # environment can be built on your machine.
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      with epnix.lib;
      let
        result = evalEpnixModules system myEpnixDistribution;
      in
      {
        packages = result.outputs;

        defaultPackage = self.packages.${system}.build;
        devShell = self.packages.${system}.devShell;

        checks = result.config.epnix.checks.derivations;
      });
}
