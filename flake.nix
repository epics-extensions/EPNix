{
  description = "A Nix flake containing EPICS-related modules and packages";

  inputs.bash-lib = {
    url = "github:minijackson/bash-lib";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.devshell.url = "github:numtide/devshell";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
  inputs.nix-module-doc = {
    url = "git+ssh://git@drf-gitlab.cea.fr/rnicole/nix-module-doc.git";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.epics-systemd.url = "github:minijackson/epics-systemd";

  outputs =
    { self
    , devshell
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

            devShell = pkgs.epnixLib.mkEpnixDevShell "x86_64-linux" {
              devShell.commands = [
                { package = pkgs.mdbook; }
                { package = pkgs.poetry; }
              ];
            };
          };
      in
      (eachSystem [ "x86_64-linux" ] systemDependentOutputs)
      // {
        inherit overlay;

        lib = import ./lib {
          lib = nixpkgs.lib;
          inherit inputs;
        };

        templates.top = {
          path = ./templates/top;
          description = "An EPNix TOP project";
        };

        defaultTemplate = self.templates.top;
      };
}
