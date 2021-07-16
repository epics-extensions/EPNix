{ pkgs, ... }:

with pkgs;
pkgs.recurseIntoAttrs rec {
  epics = pkgs.recurseIntoAttrs {
    base = callPackage ./epics/base { };
    support = pkgs.recurseIntoAttrs {
      asyn = callPackage ./epics/support/asyn { };
      synApps = callPackage ./epics/support/synApps { };
    };
  };
}
