{
  epnixLib,
  pkgs,
  lib,
  ...
}:
{
  name = "softioc";

  nodes = 
    let
      common = {
        environment.systemPackages = [ pkgs.epnix.epics-base7 ];
      };
    in
    {
      server = {
        imports = [ common ];

        networking.firewall = {
          allowedTCPPorts = [ 5075 ];
          allowedUDPPorts = [ 5076 ];
        };

        environment.variables = {
          TEST_VAL = "6789";
        };

        systemd.services.softioc-server = {
          wantedBy = [ "multi-user.target" ];
          wants = [ "network-online.target" ];
          after = [ "network-online.target" ];
          script =
            let
              softioc-server =
                pkgs.writers.writePython3Bin "softioc-server" { libraries = [ pkgs.python3Packages.softioc ]; }
                  ''
                    # Script taken from
                    # https://diamondlightsource.github.io/pythonSoftIOC/master/how-to/use-asyncio-in-an-ioc.html

                    # Import the basic framework components.
                    from softioc import softioc, builder, asyncio_dispatcher
                    import asyncio

                    # Create an asyncio dispatcher, the event loop is now running
                    dispatcher = asyncio_dispatcher.AsyncioDispatcher()

                    # Create some records
                    test = builder.aOut(
                        'test',
                        initial_value=0.0,
                        always_update=True,
                        on_update=lambda v: print(f"Got {v}"),
                    )

                    # Boilerplate get the IOC started
                    builder.LoadDatabase()
                    softioc.iocInit(dispatcher)

                    loop = asyncio.new_event_loop()
                    asyncio.set_event_loop(loop)
                    loop.run_forever()
                  '';
            in
            lib.getExe softioc-server;
        };
      };
    };

  testScript = ''
    start_all()

    server.wait_for_unit("softioc-server.service")

    commands = [
        "pvput test $TEST_VAL && pvget test | grep $TEST_VAL"
    ]
    for command in commands:
        res = server.succeed(f"{command}")
        print(res)
  '';
}
