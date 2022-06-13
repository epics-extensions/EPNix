{
  pkgs,
  crossArch,
  ...
}: let
  inherit (pkgs) epnixLib;
  inherit (pkgs.stdenv.hostPlatform) system;

  result = epnixLib.evalEpnixModules {
    nixpkgsConfig = {
      system = system;
      crossSystem.config = crossArch;
    };
    epnixConfig.imports = [./top/epnix.nix];
  };

  ioc = result.config.epnix.outputs.build;
  inherit (result.config.epnix.pkgs.stdenv) hostPlatform;
  iocBin = "../../bin/${epnixLib.toEpicsArch hostPlatform}/simple";
  emulator = pkgs.lib.replaceStrings ["\""] ["\\\""] (hostPlatform.emulator pkgs);
in
  pkgs.nixosTest {
    name = "cross-for-${system}";
    meta.maintainers = with epnixLib.maintainers; [minijackson];

    nodes.machine = {};

    testScript = ''
      start_all()

      machine.wait_for_unit("default.target")

      machine.succeed("echo exit | (cd ${ioc}/iocBoot/iocsimple; ${emulator} ${iocBin} ./st.cmd)")
    '';
  }
