# This tests both the phoebus-alarm-server, and phoebus-alarm-logger services
{
  epnixLib,
  lib,
  pkgs,
  ...
}: {
  name = "phoebus-alarm-server-simple-check";
  meta.maintainers = with epnixLib.maintainers; [minijackson];

  nodes = {
    server = {config, ...}: {
      services.phoebus-alarm-server = {
        enable = true;
        openFirewall = true;
        settings = {
          "org.phoebus.pv.ca/addr_list" = ["ioc"];
          "org.phoebus.pv.ca/auto_addr_list" = false;
        };
      };

      nixpkgs.config.allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [
          # Elasticsearch can be used as an SSPL-licensed software, which is
          # not open-source. But as we're using it run tests, not exposing
          # any service, this should be fine.
          "elasticsearch"
        ];

      virtualisation.memorySize = 3072;
    };

    ioc = {
      systemd.services.ioc = {
        description = "Test IOC to be monitored with the Phoebus Alarm server";
        serviceConfig.ExecStart = "${pkgs.epnix.epics-base}/bin/softIoc -S -d ${./ioc.db}";
        wantedBy = ["multi-user.target"];
        after = ["network.target"];
      };

      networking.firewall = {
        allowedTCPPorts = [5064];
        allowedUDPPorts = [5064];
      };
    };

    client = {
      environment = {
        sessionVariables.EPICS_CA_ADDR_LIST = ["ioc"];
        systemPackages = [pkgs.kcat pkgs.epnix.epics-base];
      };
    };
  };

  testScript = builtins.readFile ./alarm.py;
}
