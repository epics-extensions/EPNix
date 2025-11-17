{
  epnixLib,
  pkgs,
  ...
}:
let
  pvwsTestClient =
    pkgs.writers.writePython3Bin "pvwsTestClient"
      {
        libraries = [ pkgs.python3Packages.websockets ];
      }
      ''
        import json

        from websockets.sync.client import connect


        def main():
            with connect("ws://localhost:8080/pvws/pv") as websocket:
                ping = {"type": "ping"}
                websocket.send(json.dumps(ping))

                # Test echo

                echo = {"type": "echo", "body": "Hello, world!"}
                websocket.send(json.dumps(echo))
                message = websocket.recv(timeout=20)
                assert json.loads(message) == echo, (
                    "echo didn't return the same object"
                )

                # Test subscription

                subscribe = {"type": "subscribe", "pvs": ["calcExample"]}
                websocket.send(json.dumps(subscribe))
                message = websocket.recv(timeout=200)
                message = json.loads(websocket.recv(timeout=200))
                value = message["value"]

                message = json.loads(websocket.recv(timeout=200))
                assert message["value"] == value + 1 % 10
                value = message["value"]

                message = json.loads(websocket.recv(timeout=200))
                assert message["value"] == value + 1 % 10
                value = message["value"]

                # Test list

                websocket.send(json.dumps({"type": "list"}))
                message = json.loads(websocket.recv(timeout=200))
                assert message["pvs"] == ["calcExample"]


        if __name__ == "__main__":
            main()
      '';
in
{
  name = "dbwr-simple-check";
  meta.maintainers = with epnixLib.maintainers; [ minijackson ];

  nodes = {
    ioc.imports = [
      (epnixLib.testing.softIoc ''
        record(calc, "calcExample") {
            field(DESC, "Counter")
            field(SCAN, "1 second")
            field(CALC, "(A<B)?(A+C):D")
            field(INPA, "calcExample.VAL NPP NMS")
            field(INPB, "9")
            field(INPC, "1")
            field(INPD, "0")
            field(EGU, "Counts")
            field(HOPR, "10")
            field(HIHI, "8")
            field(HIGH, "6")
            field(LOW, "4")
            field(LOLO, "2")
            field(HHSV, "MAJOR")
            field(HSV, "MINOR")
            field(LSV, "MINOR")
            field(LLSV, "MAJOR")
        }
      '')
    ];

    server = {
      services.dbwr.enable = true;
      environment.epics = {
        ca_addr_list = [ "ioc" ];
        ca_auto_addr_list = false;
      };

      services.nginx = {
        enable = true;
        virtualHosts.localhost.locations."/".root = ./bobs;
      };

      environment.systemPackages = [ pvwsTestClient ];
    };
  };

  testScript = ''
    start_all()

    server.wait_for_unit("nginx.service")
    server.wait_for_open_port(80)

    server.wait_for_unit("tomcat.service")
    server.wait_for_open_port(8080)

    server.succeed("pvwsTestClient")
    server.succeed("curl -sSf 'http://localhost/bob.bob'")
    server.succeed("curl -sSf 'http://localhost:8080/dbwr/'")
    server.succeed("curl -sSf 'http://localhost:8080/dbwr/view.jsp?display=http://localhost/bob.bob'")
    server.succeed("curl -sSf 'http://localhost:8080/dbwr/screen?display=http://localhost/bob.bob'")
  '';
}
