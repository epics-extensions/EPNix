{
  description = "A Nix flake containing EPICS-related modules and packages";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
  inputs.bash-lib = {
    url = "github:minijackson/bash-lib";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nix-module-doc = {
    url = "git+ssh://git@drf-gitlab.cea.fr/rnicole/nix-module-doc.git";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.epics-systemd.url = "github:minijackson/epics-systemd";

  outputs =
    { self
    , flake-utils
    , nixpkgs
    , ...
    } @ inputs:
      with flake-utils.lib;
      let
        overlay = import ./pkgs self.lib;

        systemDependentOutputs = system:
          let
            pkgs = import nixpkgs {
              inherit system;
              overlays = [
                overlay
                inputs.bash-lib.overlay
                inputs.epics-systemd.overlay
              ];
            };
          in
          rec {
            packages =
              flattenTree (pkgs.recurseIntoAttrs pkgs.epnix)
              // {
                manpage = self.lib.mkEpnixManPage system { };
                mdbook = self.lib.mkEpnixMdBook system { };
              };

            checks =
              (import ./checks { inherit pkgs; })
              // {
                # The manpage and documentation should always build
                inherit (self.packages.${system}) manpage mdbook;
              };

            devShells.default = pkgs.epnixLib.mkEpnixDevShell "x86_64-linux" {
              epnix = {
                meta.name = "epnix";
                buildConfig.src = pkgs.emptyDirectory;
                devShell.packages = [
                  { package = pkgs.mdbook; category = "development tools"; }
                  { package = pkgs.poetry; category = "development tools"; }
                ];
              };
            };

            devShell = self.devShells.${system}.default;
          };
      in
      (eachSystem [ "x86_64-linux" ] systemDependentOutputs)
      // {
        overlays.default = overlay;
        overlay = self.overlays.default;

        lib = import ./lib {
          lib = nixpkgs.lib;
          inherit inputs;
        };

        templates.top = {
          path = ./templates/top;
          description = "An EPNix TOP project";
        };

        templates.default = self.templates.top;
        defaultTemplate = self.templates.default;
      };
}
