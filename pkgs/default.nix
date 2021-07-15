{ pkgs, ... }:

with pkgs;
pkgs.recurseIntoAttrs rec {
  epics = pkgs.recurseIntoAttrs {
    base = callPackage ./epics/base { };
    support = { };
  };
}
