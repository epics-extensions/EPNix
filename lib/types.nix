{ lib, ... }:

with lib;

{
  strOrPackage = pkgs:
    let
      pkgPath = splitString ".";
      resolvePkg = key: attrByPath (pkgPath key) (throw ''package "${key}" not found'') pkgs;
    in
    with types;
    coercedTo str resolvePkg package;
}
