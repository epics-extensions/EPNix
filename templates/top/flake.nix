{
  description = "EPICS IOC for <...>";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.epnix.url = "github:epics-extensions/epnix/nixos-25.05";

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
    # Add your supported systems here.
    # ---
    # "x86_64-linux" should still be specified so that the development
    # environment can be built on your machine.
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (
      system:
      let
        pkgs = import epnix.inputs.nixpkgs {
          inherit system;
          overlays = [
            epnix.overlays.default
            self.overlays.default
          ];
        };
      in
      {
        packages.default = pkgs.myIoc;

        checks = {
          simple = pkgs.callPackage ./checks/simple.nix {
            inherit (self.nixosModules) iocService;
          };
        };
      }
    )
    // {
      overlays.default = final: _prev: {
        myIoc = final.callPackage ./ioc.nix { };
      };

      nixosModules.iocService =
        { config, ... }:
        {
          services.iocs.myIoc = {
            description = "An optional description of your IOC";
            package = self.packages.x86_64-linux.default;
            # Directory where to find the 'st.cmd' file
            workingDirectory = "iocBoot/iocMyIoc";
          };

          # To open the firewall, uncomment these lines:
          #environment.epics.openCAFirewall = true;
          #environment.epics.openPVAFirewall = true;
        };

      inherit (epnix) formatter;
    };
}
