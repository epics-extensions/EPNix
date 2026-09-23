{
  epnixLib,
  lib,
  pkgs,
  ...
}:
{
  name = "softIocs";
  meta.maintainers = with epnixLib.maintainers; [ minijackson ];

  nodes = {
    client = {
      environment.systemPackages = [ pkgs.epnix.epics-base ];
      environment.epics = {
        ca_addr_list = [ "192.168.1.255" ];
        pva_addr_list = [ "192.168.1.255" ];
        allowCABroadcastDiscovery = true;
        allowPVABroadcastDiscovery = true;
      };
    };

    ioc = {
      services.softIocs = {
        ioc1 = {
          dbText = "record(ai, IOC1) {}";
          environment.EPICS_CAS_SERVER_PORT = "5066";
        };
        ioc2 = {
          dbFiles = [ (pkgs.writeText "ioc2.db" "record(ai, IOC2) {}") ];
          environment.EPICS_CAS_SERVER_PORT = "5067";
        };
        ioc3 = {
          dbFiles = [ ./softIoc.db ];
          environment.EPICS_CAS_SERVER_PORT = "5068";
        };
        ioc4 = {
          dbText = "record(ai, IOC4:1) {}";
          dbFiles = [ (pkgs.writeText "ioc4.db" "record(ai, IOC4:2) {}") ];
          environment.EPICS_CAS_SERVER_PORT = "5069";
        };
        ioc5 = {
          dbText = "record(ai, IOC5) {}";
          pvAccess.enable = true;
          environment.EPICS_CAS_SERVER_PORT = "5070";
        };
        ioc6 = {
          dbText = ''
            record(ai, $(P=)IOC6) {}
            record(calc, $(P=)IOC6:CALC) {
              field(CALC, "$(CALC)")
              field(PINI, 1)
            }
          '';
          macros = {
            P = "MY:PREFIX:";
            CALC = "2 + 2";
          };
          environment.EPICS_CAS_SERVER_PORT = "5071";
        };
      };

      services.ca-gateway = {
        enable = true;
        settings = {
          cip = map (port: "localhost:${toString port}") (lib.range 5066 5071);
          access = pkgs.writeText "ca-gateway.access" ''
            ASG(DEFAULT) {
              RULE(1, READ)
              RULE(1, WRITE)
            }
          '';
        };
      };

      services.pva-gateway = {
        enable = true;
        settings = {
          clients = [
            {
              name = "client";
              addrlist = map (port: "localhost:${toString port}") (lib.range 5066 5071);
              autoaddrlist = false;
            }
          ];
          servers = [ { name = "server"; } ];
        };
      };

      environment.epics = {
        openCAFirewall = true;
        openPVAFirewall = true;
      };
    };
  };

  extraPythonPackages = p: [ p.json5 ];

  testScript = ''
    import unittest

    import json5

    t = unittest.TestCase()

    start_all()

    client.wait_for_unit("multi-user.target")

    for i in range(1, 7):
        ioc.wait_for_unit(f"ioc{i}.service")

    for pv in [
        "IOC1",
        "IOC2",
        "IOC3",
        "IOC4:1",
        "IOC4:2",
        "IOC5",
        "MY:PREFIX:IOC6",
    ]:
        client.wait_until_succeeds(f"caput {pv} 42")
        t.assertEqual(client.succeed(f"caget -t {pv}").strip(), "42")

    t.assertEqual(client.succeed("caget -t MY:PREFIX:IOC6:CALC").strip(), "4")

    client.wait_until_succeeds("pvput IOC5 1337")
    result = json5.loads(client.succeed("pvget -M json IOC5 | cut -d' ' -f2-"))
    t.assertEqual(result["value"], 1337)
  '';
}
