{
  pkgs,
  self,
  nixpkgs,
  crossSystem,
  system-name,
  ...
}:
let
  inherit (pkgs) epnixLib;
  inherit (pkgs.stdenv.hostPlatform) system;

  crossPkgs = import nixpkgs {
    inherit system crossSystem;
    overlays = [ self.overlays.default ];
  };

  ioc = crossPkgs.epnix.support.callPackage ./ioc.nix { };

  inherit (crossPkgs.stdenv) hostPlatform;
  iocBin = "../../bin/${epnixLib.toEpicsArch hostPlatform}/simple";
  emulator = pkgs.lib.replaceStrings [ "\"" ] [ "\\\"" ] (hostPlatform.emulator pkgs);
in
pkgs.runCommand "cross-for-${system-name}"
  {
    meta.maintainers = with epnixLib.maintainers; [ minijackson ];
  }
  ''
    echo exit | (cd ${ioc}/iocBoot/iocsimple; ${emulator} ${iocBin} ./st.cmd)
    mkdir $out
  ''
