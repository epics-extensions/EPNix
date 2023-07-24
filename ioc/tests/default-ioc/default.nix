releaseBranch: {pkgs, ...}: let
  inherit (pkgs) epnixLib;
  inherit (pkgs.stdenv.hostPlatform) system;

  result = epnixLib.evalEpnixModules {
    nixpkgsConfig.system = system;
    epnixConfig.imports = [
      (import ./top/epnix.nix releaseBranch)
    ];
  };

  service = result.config.epnix.nixos.services.ioc.config;

  ioc = result.outputs.build;
in
  pkgs.nixosTest {
    name = "default-ioc-epics-base-${releaseBranch}";
    meta.maintainers = with epnixLib.maintainers; [minijackson];

    nodes.machine = {
      environment.systemPackages = [pkgs.epnix.epics-base];
      systemd.services.ioc = service;
    };

    testScript = ''
      machine.wait_for_unit("default.target")
      machine.wait_for_unit("ioc.service")

      with subtest("wait until started"):
        assert machine.wait_until_succeeds("caget -t SIMPLE:AI").strip() == "0"

      with subtest("EPICS revision is correct"):
        machine.succeed("journalctl --no-pager -u ioc.service | grep -F '## EPICS R${releaseBranch}'")

      with subtest("ai records"):
        assert machine.wait_until_succeeds("caget -t SIMPLE:AI").strip() == "0"
        machine.succeed("caput SIMPLE:AI 123.456")
        assert machine.wait_until_succeeds("caget -t SIMPLE:AI").strip() == "123.456"
    '';

    passthru = {
      inherit ioc;
    };
  }
