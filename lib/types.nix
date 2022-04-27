{lib, ...}:
with lib; let
  pkgPath = splitString ".";
  resolvePkg = pkgs: key: attrByPath (pkgPath key) (throw ''package "${key}" not found'') pkgs;
in rec {
  strOrPackage = pkgs:
    with types;
      (coercedTo str (resolvePkg pkgs) package) // {description = "package";};

  strOrFuncToPackage = pkgs: let
    packageType = strOrPackage pkgs;
    # Just add an unused argument
    resolveFunc = pkg:
      if types.package.check pkg
      then _super: pkg
      else _super: resolvePkg pkgs pkg;
  in
    with types;
      coercedTo packageType resolveFunc (functionTo package);
}
