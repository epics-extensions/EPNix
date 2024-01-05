{pkgs, ...}: let
  inherit (pkgs) epnixLib;
  inherit (pkgs.stdenv.hostPlatform) system;

  result  = epnixLib.evalEpnixModules {
    nixpkgsConfig.system = system;
    epnixConfig.imports = [./opcuaSimpleTestTop/epnix.nix];
  };

  service = result.config.epnix.nixos.service.config;

  ioc = result.outputs.build;
in
  pkgs.nixosTest {
    name = "support-opcua-simple";
    meta.maintainers = with epnixLib.maintainers; [vivien];

    nodes.machine = {
      environment.systemPackages = [pkgs.epnix.epics-base pkgs.inetutils];

      systemd.services.ioc = service;
    };

    testScript = ''
      # test script in Python

      machine.wait_for_unit("default.target")
      machine.wait_for_unit("ioc.service")

      # implement your test logic in Python here

    '';

    passthru = {
      inherit ioc;
    };
  }
