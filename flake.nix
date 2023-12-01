{
  description = "A Nix flake containing EPICS-related modules and packages";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
  inputs.bash-lib = {
    url = "github:minijackson/bash-lib";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    ...
  } @ inputs: let
    overlay = import ./pkgs self.lib;

    systemDependentOutputs = system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [overlay inputs.bash-lib.overlay];
      };
    in {
      packages = flake-utils.lib.flattenTree pkgs.epnix;

      checks =
        {
          # Everything should always build
          allPackages = pkgs.releaseTools.aggregate {
            name = "allPackages";
            constituents = builtins.attrValues self.packages.${system};
          };
        }
        // (import ./ioc/tests {inherit pkgs self;})
        // (import ./nixos/tests/all-tests.nix {inherit nixpkgs pkgs self system;});

      devShells.default = pkgs.epnixLib.mkEpnixDevShell {
        nixpkgsConfig.system = system;
        epnixConfig.epnix = {
          meta.name = "epnix";
          buildConfig.src = pkgs.emptyDirectory;
          devShell.packages = [
            {
              package = pkgs.poetry;
              category = "development tools";
            }
            {
              package = pkgs.quarto;
              category = "development tools";
            }
            {
              package = pkgs.vale;
              category = "development tools";
            }
          ];
        };
      };

      devShell = self.devShells.${system}.default;
    };
  in
    # Not eachDefaultSystem right now, because `nix flake check` tries to
    # build every derivation of every system, which fails.
    # Waiting on: https://github.com/NixOS/nix/pull/7759
    (flake-utils.lib.eachSystem ["x86_64-linux"] systemDependentOutputs)
    // {
      overlays.default = overlay;

      lib = let
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

      nixosModules.nixos = {lib, ...}: {
        imports = import ./nixos/module-list.nix;
        # use mkBefore so that end users can be sure
        # that their overlay can override EPNix packages
        nixpkgs.overlays = lib.mkBefore [self.overlays.default];
        _module.args.epnixLib = self.lib;
      };

      templates.top = {
        path = ./templates/top;
        description = "An EPNix TOP project";
        welcomeText = ''
          You have created an EPNix top.

          Don't forget to run `makeBaseApp.pl` and `eregen` inside the development shell before compiling it.

          Useful links:

          - EPNix IOC documentation: <https://epics-extensions.github.io/EPNix/ioc/introduction.html>
          - Getting Started: <https://epics-extensions.github.io/EPNix/ioc/tutorials/getting-started.html>
        '';
      };

      templates.default = self.templates.top;
      defaultTemplate = self.templates.default;

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
    };
}
