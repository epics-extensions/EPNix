{
  description = "NixOS configuration for the phoebus-ecosystem image";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/${EPNIX_STABLE}";
    epnix = {
      url = "github:epics-extensions/EPNix/${EPNIX_BRANCH}";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      epnix,
    }:
    {
      nixosConfigurations."${HOSTNAME}" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          epnix.nixosModules.nixos
          ./configuration.nix
          ./hardware-configuration.nix
        ];
      };
    };
}
