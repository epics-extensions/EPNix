{
  lib,
  epnixLib,
  ...
}: {
  name = "phoebus-olog-simple-check";
  meta.maintainers = with epnixLib.maintainers; [minijackson];

  nodes = {
    server = {pkgs, ...}: {
      services.phoebus-olog = {
        enable = true;
        settings."demo_auth.enabled" = true;
      };

      services.elasticsearch = {
        enable = true;
        package = pkgs.elasticsearch7;
      };

      nixpkgs.config.allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [
          # Elasticsearch can be used as an SSPL-licensed software, which is
          # not open-source. But as we're using it run tests, not exposing
          # any service, this should be fine.
          "elasticsearch"

          # MongoDB also uses the SSPL.
          "mongodb"
        ];

      networking.firewall.allowedTCPPorts = [8181];

      # Else phoebus-olog gets killed by the OOM killer
      virtualisation.memorySize = 2047;
    };

    client = {};
  };

  testScript = ''
    import json
    from typing import Any

    start_all()

    server.wait_for_unit("phoebus-olog.service")
    server.wait_for_open_port(8181)

    client.wait_for_unit("multi-user.target")

    # TODO: properly configure certificates
    status_str = client.succeed("curl -sSfL -k https://server:8181/Olog")
    status = json.loads(status_str)

    with subtest("Olog connected to ElasticSearch"):
        assert status["elastic"]["status"] == "Connected"

    with subtest("Olog connected to MongoDB"):
        assert "state=CONNECTED" in status["mongoDB"]

    def get(uri: str) -> Any:
        result = client.succeed(f"curl -sSfL -k https://server:8181/Olog{uri}")
        return json.loads(result)

    def put(uri: str, data: Any) -> Any:
        result = client.succeed(
            f"""
                curl -sSfL -k -X PUT -u admin:adminPass \
                  'https://server:8181/Olog{uri}' \
                  -H 'Content-Type: application/json' \
                  -d {repr(json.dumps(data))}
        """
        )
        return json.loads(result)

    with subtest("can fetch logbooks"):
        logbooks = get("/logbooks")
        assert len(logbooks) > 0, "No default logbook found"

    with subtest("can login"):
        client.succeed("curl -sSfL -k -X POST 'https://server:8181/Olog/login?username=admin&password=adminPass' --cookie-jar cjar")
        user_str = client.succeed("curl -sSfL -k 'https://server:8181/Olog/user' --cookie cjar")
        user = json.loads(user_str)
        assert user["userName"] == "admin"

    log_id = -1

    with subtest("can put logs"):
        the_log = put(
            "/logs",
            {
                "owner": "log",
                "title": "The title",
                "description": "The description",
                "level": "Info",
                "logbooks": [{"name": "operations"}],
            },
        )
        log_id = the_log["id"]

    with subtest("can get log back"):
        the_log = get(f"/logs/{log_id}")
        assert the_log["title"] == "The title"
  '';
}
