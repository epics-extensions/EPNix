{pkgs, ...}: let
  inherit (pkgs) epnixLib;
  inherit (pkgs.stdenv.hostPlatform) system;

  result = epnixLib.evalEpnixModules {
    nixpkgsConfig.system = system;
    epnixConfig.imports = [./pvxsStandaloneServerTestTop/epnix.nix];
  };

  ioc = result.outputs.build;
in
  pkgs.nixosTest {
    name = "support-pvxs-standalone-server";
    meta.maintainers = with epnixLib.maintainers; [minijackson];

    nodes = {
      client = {
        environment.systemPackages = [
          pkgs.epnix.epics-base
          pkgs.epnix.support.pvxs
        ];
        networking.firewall.allowedTCPPorts = [5075];
        networking.firewall.allowedUDPPorts = [5076];
      };
      ioc = {
        systemd.services.ioc = {
          wantedBy = ["multi-user.target"];
          wants = ["network-online.target"];
          after = ["network-online.target"];

          description = "EPICS PVXS standalone IOC server";

          serviceConfig = {
            ExecStart = "${ioc}/bin/mailboxServer";
            Restart = "always";
          };
        };
        networking.firewall.allowedTCPPorts = [5075];
        networking.firewall.allowedUDPPorts = [5076];
      };
    };

    testScript = ''
      import json

      start_all()

      addr_list = "EPICS_PVA_ADDR_LIST=192.168.1.2"

      def pvget(name: str):
        return json.loads(client.succeed(f"{addr_list} pvget {name} -M json | cut -d' ' -f2-"))

      def pvxget(name: str):
        output = client.succeed(f"{addr_list} pvxget {name}")
        return output.splitlines()[1].split()[-1]

      def _pvput(utility: str, name: str, value: str):
        client.succeed(f"{addr_list} {utility} {name} {value}")

      def pvput(name: str, value: str):
        _pvput("pvput", name, value)

      def pvxput(name: str, value: str):
        _pvput("pvxput", name, value)

      with subtest("wait until IOC starts"):
        ioc.wait_for_unit("ioc.service")
        client.wait_until_succeeds(f"{addr_list} pvget my:pv:name", timeout=60)

      with subtest("PV has the correct value"):
        value = pvget("my:pv:name")
        assert value["value"] == 42
        assert value["display"]["description"] == "My PV description"

      with subtest("PV can be set"):
        pvput("my:pv:name", "1337")
        # PV is clipped
        assert pvget("my:pv:name")["value"] == 100

      with subtest("PVXS command-line utilities work"):
        assert pvxget("my:pv:name") == "100"
        pvxput("my:pv:name", "42")
        assert pvxget("my:pv:name") == "42"
        client.succeed(f"{addr_list} pvxinfo my:pv:name")
    '';

    passthru = {
      inherit ioc;
    };
  }
