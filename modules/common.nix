{ config, lib, ... }:

with lib;
{
  options = {
    nixpkgs.overlays = mkOption {
      default = [ ];
      type = types.listOf types.unspecified;
      description = "Nixpkgs overlays to override the default packages used";
    };

    epnix.build = mkOption {
      internal = true;
      default = { };
      type = types.attrs;
    };
  };
}
