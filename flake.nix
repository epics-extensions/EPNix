{
  description = "A Nix flake containing EPICS-related modules and packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    bash-lib = {
      url = "github:minijackson/bash-lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    sphinxcontrib-nixdomain = {
      url = "github:minijackson/sphinxcontrib-nixdomain";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sphinxcontrib-typstbuilder = {
      url = "github:minijackson/sphinxcontrib-typstbuilder";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-github-actions = {
      url = "github:nix-community/nix-github-actions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      flake-utils,
      nixpkgs,
      nix-github-actions,
      ...
    }@inputs:
    let
      overlay = import ./pkgs self.lib inputs;

      systemDependentOutputs =
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              overlay
              inputs.bash-lib.overlay
              inputs.sphinxcontrib-nixdomain.overlays.default
              inputs.sphinxcontrib-typstbuilder.overlays.default
            ];
          };
        in
        {
          packages = flake-utils.lib.flattenTree pkgs.epnix;

          checks =
            {
              # Everything should always build
              allPackages = pkgs.releaseTools.aggregate {
                name = "allPackages";
                constituents = builtins.attrValues self.packages.${system};
              };
            }
            // (import ./pkgs/tests { inherit pkgs self; })
            // (import ./ioc/tests {
              inherit
                nixpkgs
                pkgs
                self
                system
                ;
            })
            // (import ./nixos/tests/all-tests.nix {
              inherit
                nixpkgs
                pkgs
                self
                system
                ;
            });

          devShells.default = pkgs.mkShell {
            packages = [
              pkgs.epnix.epics-base
              pkgs.vale
            ];
            inputsFrom = [
              pkgs.epnix.docs
            ];
          };
        };
    in
    # Not eachDefaultSystem right now, because `nix flake check` tries to
    # build every derivation of every system, which fails.
    # Waiting on: https://github.com/NixOS/nix/pull/7759
    (flake-utils.lib.eachSystem [ "x86_64-linux" ] systemDependentOutputs)
    // {
      overlays.default = overlay;

      lib =
        let
          epnixLib = import ./lib {
            inherit (nixpkgs) lib;
            inherit epnixLib inputs;
          };
        in
        epnixLib;

      nixosModules.default = {
        imports = [
          self.nixosModules.ioc
          self.nixosModules.nixos
        ];
      };

      nixosModules.ioc = {
        imports = import ./ioc/modules/module-list.nix;
        _module.args.epnix = self;
      };

      nixosModules.nixos =
        { lib, ... }:
        {
          imports = import ./nixos/module-list.nix;
          # use mkBefore so that end users can be sure
          # that their overlay can override EPNix packages
          nixpkgs.overlays = lib.mkBefore [ self.overlays.default ];
          _module.args.epnixLib = self.lib;
        };

      templates.top = {
        path = ./templates/top;
        description = "An EPNix TOP project";
        welcomeText = ''
          You have created an EPNix top.

          Don't forget to run `makeBaseApp.pl` and `eregen` inside the development shell before compiling it.

          Useful links:

          - EPNix IOC documentation: <https://epics-extensions.github.io/EPNix/${self.lib.versions.stable}/ioc/>
          - EPNix IOC tutorials: <https://epics-extensions.github.io/EPNix/${self.lib.versions.stable}/ioc/tutorials/>
        '';
      };

      templates.new-top = {
        path = ./templates/new-top;
        description = "An EPNix TOP project (next-generation)";
        welcomeText = ''
          You have created a next-generation EPNix top.

          Don't forget to run `makeBaseApp.pl` and `epicsConfigurePhase` inside the development shell before compiling it.

          Useful links:

          - EPNix IOC documentation: <https://epics-extensions.github.io/EPNix/${self.lib.versions.stable}/ioc/>
          - EPNix IOC tutorials: <https://epics-extensions.github.io/EPNix/${self.lib.versions.stable}/ioc/tutorials/>
        '';
      };

      templates.default = self.templates.top;

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.callPackage ./formatter.nix { };

      githubActions = nix-github-actions.lib.mkGithubMatrix { inherit (self) checks; };
    };
}
