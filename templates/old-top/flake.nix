{
  description = "EPICS IOC for <...>";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.epnix.url = "github:epics-extensions/epnix/nixos-25.11";

  # If you have a support module as a separate EPNix repository,
  # add it as an input here:
  # ---
  #inputs.mySupportModule = {
  #  url = "git+ssh://git@my-server.org/me/exampleApp.git";
  #  inputs.epnix.follows = "epnix";
  #};

  # If you have an "App" as a separate repository,
  # add it as an input here:
  # ---
  #inputs.exampleApp = {
  #  url = "git+ssh://git@my-server.org/me/exampleApp.git";
  #  flake = false;
  #};

  outputs =
    {
      self,
      flake-utils,
      epnix,
      ...
    }@inputs:
    let
      myEpnixConfig =
        { pkgs, ... }:
        {
          # Set your EPNix options here
          # ---

          # If you have a support module as a separate EPNix repository,
          # uncomment this line to make the package available:
          # ---
          #nixpkgs.overlays = [inputs.mySupportModule.overlays.default];

          epnix = {
            inherit inputs;

            # Change this to be the name of your EPICS top
            # ---
            meta.name = "my-top";

            # You can choose the version of EPICS-base here:
            # ---
            #epics-base.releaseBranch = "3"; # Defaults to "7"

            # Add your support modules here:
            # ---
            #support.modules = with pkgs.epnix.support; [ StreamDevice mySupportModule ];

            # If you have an "App" as a separate repository,
            # add it here:
            # ---
            #applications.apps = [ "inputs.exampleApp" ];

            # Add your integration tests:
            # ---
            checks.imports = [ ./checks/simple.nix ];

            # Used when generating NixOS systemd services, for example for
            # deployment to production, or for the NixOS tests in checks/
            # ---
            nixos.services.ioc = {
              app = "example";
              ioc = "iocExample";
            };

            # You can specify environment variables in your development shell like this:
            # ---
            #devShell.environment.variables = {
            #  EPICS_CA_ADDR_LIST = "localhost";
            #  MY_VARIABLE = "the_value";
            #};
          };
        };
    in
    # Add your supported systems here.
    # ---
    # "x86_64-linux" should still be specified so that the development
    # environment can be built on your machine.
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (
      system:
      let
        epnixDistribution = epnix.lib.evalEpnixModules {
          nixpkgsConfig = {
            # This specifies the build architecture
            inherit system;

            # This specifies the host architecture, uncomment for cross-compiling
            #
            # The complete of example architectures is here:
            # https://github.com/NixOS/nixpkgs/blob/nixos-22.11/lib/systems/examples.nix
            # ---
            #crossSystem = epnix.inputs.nixpkgs.lib.systems.examples.armv7l-hf-multiplatform;
          };
          epnixConfig = myEpnixConfig;
        };
      in
      {
        packages = epnixDistribution.outputs // {
          default = self.packages.${system}.build;
        };

        inherit epnixDistribution;

        devShells.default = self.packages.${system}.devShell;

        checks = epnixDistribution.config.epnix.checks.derivations;
      }
    )
    // {
      overlays.default = final: prev: self.epnixDistribution.x86_64-linux.generatedOverlay final prev;

      inherit (epnix) formatter;
    };
}
