{pkgs, ...}: let
  inherit (pkgs) epnixLib;
  inherit (pkgs.stdenv.hostPlatform) system;

  result = epnixLib.evalEpnixModules {
    nixpkgsConfig.system = system;
    epnixConfig.imports = [./top/epnix.nix];
  };

  service = result.config.epnix.nixos.service.config;

  ioc = result.outputs.build;
in
  pkgs.nixosTest {
    name = "support-seq-simple";
    meta.maintainers = with epnixLib.maintainers; [minijackson];

    nodes.machine = {
      environment.systemPackages = [pkgs.epnix.epics-base];

      systemd.services.ioc = service;
    };

    testScript = ''
      machine.wait_for_unit("default.target")
      machine.wait_for_unit("ioc.service")

      with subtest("initial state"):
        machine.wait_until_succeeds("caget -t state | grep -qxF '0'")

      with subtest("state 1"):
        machine.succeed("caput val 1")
        machine.wait_until_succeeds("caget -t state | grep -qxF '1'")

      with subtest("state 2"):
        machine.succeed("caput val 2")
        machine.wait_until_succeeds("caget -t state | grep -qxF '2'")

      with subtest("state end"):
        machine.sleep(7)
        machine.wait_until_succeeds("caget -t state | grep -qxF '3'")
    '';

    passthru = {
      inherit ioc;
    };
  }
