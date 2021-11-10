{ lib, ... }:

# Taken from:
# https://github.com/NixOS/nixpkgs/blob/55ad138e5cd97c6415abb45fae653fd413bef869/lib/licenses.nix

lib.mapAttrs (lname: lset: let
  defaultLicense = rec {
    shortName = lname;
    free = true; # Most of our licenses are Free, explicitly declare unfree additions as such!
    deprecated = false;
  };

  mkLicense = licenseDeclaration: let
    applyDefaults = license: defaultLicense // license;
    applySpdx = license:
      if license ? spdxId
      then license // { url = "https://spdx.org/licenses/${license.spdxId}.html"; }
      else license;
    applyRedistributable = license: { redistributable = license.free; } // license;
  in lib.pipe licenseDeclaration [
    applyDefaults
    applySpdx
    applyRedistributable
  ];
in mkLicense lset) ({
  epics = {
    spdxId = "EPICS";
    fullName = "EPICS Open License";
  };
})
