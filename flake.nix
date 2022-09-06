{
  description = "A Nix flake containing EPICS-related modules and packages";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
  inputs.bash-lib = {
    url = "github:minijackson/bash-lib";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nix-module-doc = {
    url = "git+ssh://git@drf-gitlab.cea.fr/rnicole/nix-module-doc.git";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    ...
  } @ inputs:
    with flake-utils.lib; let
      overlay = import ./pkgs self.lib;

      systemDependentOutputs = system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [overlay inputs.bash-lib.overlay];
        };
      in rec {
        packages =
          flattenTree (pkgs.recurseIntoAttrs pkgs.epnix)
          // {
            manpage = self.lib.mkEpnixManPage {
              nixpkgsConfig.system = system;
              epnixConfig = {};
            };
            mdbook = self.lib.mkEpnixMdBook {
              nixpkgsConfig.system = system;
              epnixConfig = {};
            };
          };

        checks = {
          # Everything should always build
          allPackages = pkgs.releaseTools.aggregate {
            name = "allPackages";
            constituents = builtins.attrValues self.packages.${system};
          };
        } // (import ./checks {inherit pkgs self;});

        devShells.default = pkgs.epnixLib.mkEpnixDevShell {
          nixpkgsConfig.system = "x86_64-linux";
          epnixConfig.epnix = {
            meta.name = "epnix";
            buildConfig.src = pkgs.emptyDirectory;
            devShell.packages = [
              {
                package = pkgs.mdbook;
                category = "development tools";
              }
              {
                package = pkgs.poetry;
                category = "development tools";
              }
            ];
          };
        };

        devShell = self.devShells.${system}.default;
      };
    in
      (eachSystem ["x86_64-linux"] systemDependentOutputs)
      // {
        overlays.default = overlay;

        lib = import ./lib {
          lib = nixpkgs.lib;
          inherit inputs;
        };

        nixosModules.default = let
          docParams = {
            outputAttrPath = ["epnix" "outputs"];
            optionsAttrPath = ["epnix" "doc"];
          };
        in {
          imports =
            [
              (inputs.nix-module-doc.lib.modules.doc-options-md docParams)
              (inputs.nix-module-doc.lib.modules.manpage docParams)
              (inputs.nix-module-doc.lib.modules.mdbook docParams)
            ]
            ++ import ./modules/module-list.nix;

            _module.args.epnix = self;
        };

        templates.top = {
          path = ./templates/top;
          description = "An EPNix TOP project";
        };

        templates.default = self.templates.top;
        defaultTemplate = self.templates.default;
      };
}
