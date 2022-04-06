{
  description = "EPICS IOC for <...>";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.epnix.url = "git+ssh://git@drf-gitlab.cea.fr/EPICS/epnix/epnix.git";

  # Add your app inputs here:
  # ---
  #inputs.exampleApp = {
  #  url = "git+ssh://git@my-server.org/me/exampleApp.git";
  #  flake = false;
  #};

  outputs = { self, flake-utils, epnix, ... } @ inputs:
    let
      myEpnixDistribution = { pkgs, ... }: {
        # Set your EPNix options here
        # ---

        epnix = {
          inherit inputs;

          # Change this to be the name of your EPICS top
          # ---
          meta.name = "my-top";

          # You can choose the version of EPICS-base here:
          # ---
          #releaseBranch = "3"; # Defaults to "7"

          # Add one of the supported modules here:
          # ---
          #support.modules = with pkgs.epnix.support; [ StreamDevice ];

          # Add your applications:
          # Note that flake inputs must be quoted in this context
          # ---
          #applications.apps = [ "inputs.exampleApp" ];

          # Add your integration tests:
          # ---
          checks.files = [ ./checks/simple.nix ];
        };

        # You can specify environment variables in your development shell like this:
        # ---
        #devShell.env = [
        #  { name = "EPICS_CA_ADDR_LIST"; value = "localhost"; }
        #  { name = "MY_VARIABLE"; value = "the_value"; }
        #];
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
        packages = result.outputs // {
          default = self.packages.${system}.build;
        };

        defaultPackage = self.packages.${system}.default;

        devShells.default = self.packages.${system}.devShell;
        devShell = self.devShells.${system}.default;

        checks = result.config.epnix.checks.derivations;
      });
}
