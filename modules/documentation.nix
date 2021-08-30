nixpkgs:

{ config, lib, pkgs, ... }:

with lib;

{
  imports = [
    "${nixpkgs}/nixos/modules/misc/meta.nix"
  ];

  config.meta.doc = ./documentation.xml;

  config.epnix.build.manual = import "${nixpkgs}/nixos/doc/manual/default.nix" {
    inherit config pkgs;

    version = "";
    revision = "";

    options = evalModules {
      modules = import ./module-list.nix;
      args = config._module.args;
    };
  };
}
