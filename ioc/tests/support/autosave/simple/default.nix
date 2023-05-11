{pkgs, ...}: let
  inherit (pkgs) epnixLib;
  inherit (pkgs.stdenv.hostPlatform) system;

  result = epnixLib.evalEpnixModules {
    nixpkgsConfig.system = system;
    epnixConfig.imports = [./autosaveSimpleTestTop/epnix.nix];
  };

  service = result.config.epnix.nixos.service.config;

  ioc = result.outputs.build;
in
  pkgs.nixosTest {
    name = "support-autosave-simple";
    meta.maintainers = with epnixLib.maintainers; [stephane];

    nodes.machine = {
      environment.systemPackages = [pkgs.epnix.epics-base pkgs.inetutils];

      systemd.services.ioc = pkgs.lib.mkMerge [service {serviceConfig.StateDirectory = "epics/autosave";}];
    };

    testScript = ''
      # test script in Python

      machine.wait_for_unit("default.target", timeout=60)

      with subtest("wait until IOC starts"):
        machine.wait_for_unit("ioc.service", timeout=60)
        machine.wait_until_succeeds("caget autosave:test:stringout", timeout=60)

      with subtest("initialize values"):
        machine.succeed("caput autosave:test:aai 5 1 2 3 4 5", timeout=1)
        machine.succeed("caput autosave:test:aao 5 1 2 3 4 5", timeout=1)
        machine.succeed("caput autosave:test:ai 42", timeout=1)
        machine.succeed("caput autosave:test:ao 42", timeout=1)
        machine.succeed("caput autosave:test:bi 1", timeout=1)
        machine.succeed("caput autosave:test:bo 1", timeout=1)
        machine.succeed("caput autosave:test:calc 42", timeout=1)
        machine.succeed("caput autosave:test:calcout 42", timeout=1)
        machine.succeed("caput autosave:test:longin 42", timeout=1)
        machine.succeed("caput autosave:test:longout 42", timeout=1)
        machine.succeed("caput autosave:test:lsi 'lsi test'", timeout=1)
        machine.succeed("caput autosave:test:lso 'lso test'", timeout=1)
        machine.succeed("caput autosave:test:mbbi 15", timeout=1)
        machine.succeed("caput autosave:test:mbbi.ZRVL 100", timeout=1)
        machine.succeed("caput autosave:test:mbbi.FFVL 115", timeout=1)
        machine.succeed("caput autosave:test:mbbi.ONST 'mbbi ONST test'", timeout=1)
        machine.succeed("caput autosave:test:mbbi.FFST 'mbbi FFST test'", timeout=1)
        machine.succeed("caput autosave:test:mbbiDirect 32", timeout=1)
        machine.succeed("caput autosave:test:mbbo 15", timeout=1)
        machine.succeed("caput autosave:test:mbbo.ZRVL 100", timeout=1)
        machine.succeed("caput autosave:test:mbbo.FFVL 115", timeout=1)
        machine.succeed("caput autosave:test:mbbo.ONST 'mbbo ONST test'", timeout=1)
        machine.succeed("caput autosave:test:mbbo.FFST 'mbbo FFST test'", timeout=1)
        machine.succeed("caput autosave:test:mbboDirect.B5 1", timeout=1)
        machine.succeed("caput autosave:test:stringin 'stringin test'", timeout=1)
        machine.succeed("caput autosave:test:stringout 'stringout test'", timeout=1)
        machine.succeed("caput autosave:test:waveform 'waveform test'", timeout=1)

      with subtest("wait 20s for autosave to trigger a save"):
        machine.succeed("sleep 20", timeout=21)

      with subtest("restart ioc service"):
        machine.systemctl("restart ioc")

      with subtest("wait until IOC starts"):
        machine.wait_for_unit("ioc.service", timeout=60)
        machine.wait_until_succeeds("caget autosave:test:stringout", timeout=60)

      with subtest("check values have been restored after restart"):
        machine.succeed("caget -t autosave:test:aai | grep -qxF '5 1 2 3 4 5'", timeout=1)
        machine.succeed("caget -t autosave:test:aao | grep -qxF '5 1 2 3 4 5'", timeout=1)
        machine.succeed("caget -t autosave:test:ai | grep -qxF '42'", timeout=1)
        machine.succeed("caget -t autosave:test:ao | grep -qxF '42'", timeout=1)
        machine.succeed("caget -t -n autosave:test:bi | grep -qxF 1", timeout=1)
        machine.succeed("caget -t -n autosave:test:bo | grep -qxF 1", timeout=1)
        machine.succeed("caget -t autosave:test:calc | grep -qxF 42", timeout=1)
        machine.succeed("caget -t autosave:test:calcout | grep -qxF 42", timeout=1)
        machine.succeed("caget -t autosave:test:longin | grep -qxF 42", timeout=1)
        machine.succeed("caget -t autosave:test:longout | grep -qxF 42", timeout=1)
        machine.succeed("caget -t autosave:test:lsi | grep -qxF 'lsi test'", timeout=1)
        machine.succeed("caget -t autosave:test:lso | grep -qxF 'lso test'", timeout=1)
        machine.succeed("caget -t -n autosave:test:mbbi | grep -qxF 15", timeout=1)
        machine.succeed("caget -t autosave:test:mbbi.ZRVL | grep -qxF 100", timeout=1)
        machine.succeed("caget -t autosave:test:mbbi.FFVL | grep -qxF 115", timeout=1)
        machine.succeed("caget -t autosave:test:mbbi.ONST | grep -qxF 'mbbi ONST test'", timeout=1)
        machine.succeed("caget -t autosave:test:mbbi.FFST | grep -qxF 'mbbi FFST test'", timeout=1)
        machine.succeed("caget -t autosave:test:mbbiDirect | grep -qxF 32", timeout=1)
        machine.succeed("caget -t autosave:test:mbbiDirect.B5 | grep -qxF 1", timeout=1)
        machine.succeed("caget -t -n autosave:test:mbbo | grep -qxF 15", timeout=1)
        machine.succeed("caget -t autosave:test:mbbo.ZRVL | grep -qxF 100", timeout=1)
        machine.succeed("caget -t autosave:test:mbbo.FFVL | grep -qxF 115", timeout=1)
        machine.succeed("caget -t autosave:test:mbbo.ONST | grep -qxF 'mbbo ONST test'", timeout=1)
        machine.succeed("caget -t autosave:test:mbbo.FFST | grep -qxF 'mbbo FFST test'", timeout=1)
        machine.succeed("caget -t autosave:test:mbboDirect | grep -qxF 32", timeout=1)
        machine.succeed("caget -t autosave:test:mbboDirect.B5 | grep -qxF 1", timeout=1)
        machine.succeed("caget -t autosave:test:stringin | grep -qxF 'stringin test'", timeout=1)
        machine.succeed("caget -t autosave:test:stringout | grep -qxF 'stringout test'", timeout=1)
        machine.succeed("caget -t autosave:test:waveform | grep -qxF 'waveform test'", timeout=1)
    '';

    passthru = {
      inherit ioc;
    };
  }
