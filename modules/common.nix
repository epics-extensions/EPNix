{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  options = {
    nixpkgs.overlays = mkOption {
      default = [];
      type = types.listOf types.unspecified;
      description = "Nixpkgs overlays to override the default packages used";
    };

    epnix.inputs = mkOption {
      description = ''
        The flake inputs of your project.

        This allows resolving things like `"inputs.myExampleApp"` in the
        `epnix.applications.apps` configuration option.
      '';
      type = types.attrs;
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
      default = {};
      type = types.attrs;
    };

    epnix.pkgs = mkOption {
      description = ''
        Contains the set of packages effectively used by this distribution.

        This means for example that the `epics-base` package will refer to the
        release branch 3 or 7, depending on the
        `epnix.epics-base.releaseBranch` option value, and so on.

        These packages will be available as the `legacyPackages` flake output.

        This option is read-only. To modify a set of packages, please use the
        `nixpkgs.overlays` option.
      '';
      default = pkgs;
      defaultText = literalExpression "<the effective used packages>";
      readOnly = true;
      type = types.attrs;
    };
  };
}
