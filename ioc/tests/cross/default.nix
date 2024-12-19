{
  pkgs,
  crossSystem,
  system-name,
  ...
}: let
  inherit (pkgs) epnixLib;
  inherit (pkgs.stdenv.hostPlatform) system;

  result = epnixLib.evalEpnixModules {
    nixpkgsConfig = {
      inherit system crossSystem;
    };
    epnixConfig.imports = [./top/epnix.nix];
  };

  ioc = result.config.epnix.outputs.build;
  inherit (result.config.epnix.pkgs.stdenv) hostPlatform;
  iocBin = "../../bin/${epnixLib.toEpicsArch hostPlatform}/simple";
  emulator = pkgs.lib.replaceStrings ["\""] ["\\\""] (hostPlatform.emulator pkgs);
in
  pkgs.runCommand "cross-for-${system-name}" {
    meta.maintainers = with epnixLib.maintainers; [minijackson];
  } ''
    echo exit | (cd ${ioc}/iocBoot/iocsimple; ${emulator} ${iocBin} ./st.cmd)
    mkdir $out
  ''
