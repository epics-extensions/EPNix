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

        `build`
          ~ The actual build of this distribution.

        `manpage`
          ~ A manpage of EPNix options.

        `mdbook`
          ~ The documentation book of the EPNix project, including your
            available module options.

        `doc-options-md`
          ~ A markdown file describing the available module options.
      '';
      default = { };
      type = types.attrs;
    };
  };
}
