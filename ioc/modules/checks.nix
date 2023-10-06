{
  config,
  epnix,
  epnixConfig,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.epnix.checks;
in {
  imports = [
    (mkRenamedOptionModule ["epnix" "checks" "files"] ["epnix" "checks" "imports"])
  ];

  options.epnix.checks = {
    imports = mkOption {
      description = ''
        A list of `.nix` files containing integration tests.

        Alternatively, a raw configuration can be specified.

        Please refer to the documentation book guide "Writing integration
        tests" for instructions on how to write these `.nix` files.
      '';
      type = with types; listOf (oneOf [path attrs (functionTo attrs)]);
      default = [];
      example = lib.literalExpression "[./checks/simple.nix]";
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
    importCheck = check: let
      params = {
        inherit pkgs epnix epnixConfig;

        build =
          lib.warn
          ''
            using 'build' in a check is deprecated.
            Please see the current EPNix IOC template for the new way of implementing checks:

            - ${epnix}/templates/top/checks/simple.nix
          ''
          config.epnix.outputs.build;
      };

      # Do different things,
      # depending on if the check is a file, an attrSet, or a function
      switch = {
        path = path: import path params;
        set = set: set;
        lambda = lambda: lambda params;
      };

      importedCheck =
        switch."${builtins.typeOf check}" check;

      inherit (importedCheck.config) name;
    in
      nameValuePair name importedCheck;
  in
    listToAttrs (map importCheck cfg.imports);
}
