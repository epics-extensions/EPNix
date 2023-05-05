{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.epnix.checks;
in {
  options.epnix.checks = {
    files = mkOption {
      description = ''
        A list of `.nix` files containing integration tests.

        Please refer to the documentation book guide "Writing integration
        tests" for instructions on how to write these `.nix` files.
      '';
      type = with types; listOf path;
      default = [];
      example = ["./checks/simple.nix"];
    };

    derivations = mkOption {
      description = ''
        The integration tests, as an attribute set of derivation, which is the
        format understood by `nix flake check`.
      '';
      type = with types; attrsOf package;
      internal = true;
      readOnly = true;
    };
  };

  config.epnix.checks.derivations = let
    checkName = path:
      pipe path [
        baseNameOf
        (splitString ".")
        head
      ];

    importCheck = path:
      import path {
        inherit pkgs;
        inherit (config.epnix.outputs) build;
      };
  in
    listToAttrs
    (forEach
      cfg.files
      (file: nameValuePair (checkName file) (importCheck file)));
}
