{
  epnixLib,
  pkgs,
  lib,
  ...
}:
{
  name = "p4p";
  meta.maintainers = with epnixLib.maintainers; [ synthetica ];

  nodes =
    let
      common = {
        environment.systemPackages =
          let
            p4p-client =
              pkgs.writers.writePython3Bin "p4p-client" { libraries = [ pkgs.python3Packages.p4p ]; }
                ''
                  from p4p.client.thread import Context
                  import random

                  ctxt = Context("pva")

                  test_val = random.randint(0, 1000)
                  ctxt.put("test", test_val)
                  val = ctxt.get("test")

                  print(val)
                  assert val == test_val
                '';
          in
          [
            pkgs.epnix.epics-base7
            p4p-client
          ];
      };
    in
    {
      client = {
        imports = [ common ];

        environment.variables = {
          EPICS_PVA_ADDR_LIST = "server";
          TEST_VAL = "1234";
        };
      };

      server = {
        imports = [ common ];

        networking.firewall = {
          allowedTCPPorts = [ 5075 ];
          allowedUDPPorts = [ 5076 ];
        };

        environment.variables = {
          TEST_VAL = "6789";
        };

        systemd.services.p4p-server = {
          wantedBy = [ "multi-user.target" ];
          wants = [ "network-online.target" ];
          after = [ "network-online.target" ];
          script =
            let
              p4p-server =
                pkgs.writers.writePython3Bin "p4p-server" { libraries = [ pkgs.python3Packages.p4p ]; }
                  ''
                    # Script taken from https://epics-base.github.io/p4p/server.html

                    from p4p.nt import NTScalar
                    from p4p.server import Server
                    from p4p.server.thread import SharedPV

                    pv = SharedPV(
                      nt=NTScalar('d'),
                      initial=0.0,
                    )


                    @pv.put
                    def handle(pv, op):
                        pv.post(op.value())
                        op.done()


                    Server.forever(providers=[{
                        'test': pv,
                    }])
                  '';
            in
            lib.getExe p4p-server;
        };
      };
    };

  testScript = ''
    import itertools

    start_all()

    server.wait_for_unit("p4p-server.service")

    commands = ["pvput test $TEST_VAL && pvget test | grep $TEST_VAL", "p4p-client"]
    machines = [client, server]
    matrix = itertools.product(machines, commands)

    for (machine, command) in matrix:
        res = machine.succeed(f"{command}")
        print(res)
  '';
}
