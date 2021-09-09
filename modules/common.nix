{ config, lib, ... }:

with lib;
{
  options = {
    nixpkgs.overlays = mkOption {
      default = [ ];
      type = types.listOf types.unspecified;
      description = "Nixpkgs overlays to override the default packages used";
    };

    epnix.outputs = mkOption {
      description = ''
        Contains an attribute set of build-products for this distribution.

        Notable examples include:

        - The actual build of this distribution (`build`)
        - A manpage of EPNix options (`manpage`)
      '';
      default = { };
      type = types.attrs;
    };
  };
}
