{
  lib,
  epnixLib,
  ...
}: {
  name = "phoebus-scan-server-simple-check";
  meta.maintainers = with epnixLib.maintainers; [synthetica];

  nodes = {
    server = {
      services.phoebus-scan-server = {
        enable = true;
        openFirewall = true;
      };
    };

    client = {};
  };

  testScript = ''
    start_all()
    server.wait_for_unit('phoebus-scan-server.service')
    print(server.succeed('systemctl status phoebus-scan-server'))
    server.wait_for_open_port(4810)
    info = client.succeed('curl http://server:4810/server/info')
    print('Server claims following info:')
    print(info)
  '';
}
