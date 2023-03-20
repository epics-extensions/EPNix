{
  description = "A Nix flake containing EPICS-related modules and packages";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
  inputs.bash-lib = {
    url = "github:minijackson/bash-lib";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nix-module-doc = {
    url = "github:minijackson/nix-module-doc";
    inputs.nixpkgs.follows = "nixpkgs";
  };

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
    in rec {
      packages =
        flake-utils.lib.flattenTree (pkgs.recurseIntoAttrs pkgs.epnix)
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

      checks =
        {
          # Everything should always build
          allPackages = pkgs.releaseTools.aggregate {
            name = "allPackages";
            constituents = builtins.attrValues self.packages.${system};
          };
        }
        // (import ./checks {inherit pkgs self;});

      devShells.default = pkgs.epnixLib.mkEpnixDevShell {
        nixpkgsConfig.system = system;
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
    # Not eachDefaultSystem right now, because `nix flake check` tries to
    # build every derivation of every system, which fails.
    # Waiting on: https://github.com/NixOS/nix/pull/7759
    (flake-utils.lib.eachSystem ["x86_64-linux"] systemDependentOutputs)
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

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
    };
}
