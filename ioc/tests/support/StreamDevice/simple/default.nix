{pkgs, ...}: let
  inherit (pkgs) epnixLib;
  inherit (pkgs.stdenv.hostPlatform) system;

  result = epnixLib.evalEpnixModules {
    nixpkgsConfig.system = system;
    epnixConfig.imports = [./top/epnix.nix];
  };

  service = result.config.epnix.nixos.services.ioc.config;

  ioc = result.outputs.build;
in
  pkgs.nixosTest {
    name = "support-StreamDevice-simple";
    meta.maintainers = with epnixLib.maintainers; [minijackson];

    nodes.machine = {lib, ...}: {
      environment.systemPackages = [pkgs.epnix.epics-base];

      systemd.services = {
        "psu-simulator" = {
          wantedBy = ["multi-user.target"];
          serviceConfig = {
            ExecStart = lib.getExe pkgs.epnix.psu-simulator;
          };
        };

        ioc = lib.mkMerge [
          service
          {environment.STREAM_PS1 = "localhost:9999";}
        ];
      };
    };

    testScript = ''
      machine.wait_for_unit("default.target")
      machine.wait_for_unit("ioc.service")

      def assert_caget(pv: str, expected: str) -> None:
        machine.wait_until_succeeds(f"caget -t '{pv}' | grep -qxF '{expected}'", timeout=10)

      def assert_caput(pv: str, value: str) -> None:
        def do_caput(_) -> bool:
          machine.succeed(f"caput '{pv}' '{value}'")
          status, _output = machine.execute(f"caget -t '{pv}' | grep -qxF '{value}'")
          return status == 0

        retry(do_caput, timeout=10)

      with subtest("getting initial values"):
        assert_caget("UCmd", "0")
        assert_caget("URb", "0")
        assert_caget("PowerCmd", "ON")
        assert_caget("PowerRb", "ON")

      with subtest("setting values"):
        assert_caput("UCmd", "10")
        assert_caget("URb", "10")

      with subtest("calc integration"):
        assert_caput("2UCmd.A", "42")
        assert_caget("2UCmd.SVAL", "184")
        assert_caget("URb", "184")

      with subtest("regular expressions"):
        assert_caget("VersionNum", "0.1.0")
        assert_caget("VersionCat", "010")
    '';

    passthru = {
      inherit ioc;
    };
  }
