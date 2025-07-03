{
  epnixLib,
  pkgs,
  ...
}:
{
  name = "archiver-appliance-simple-check";
  meta.maintainers = with epnixLib.maintainers; [ minijackson ];

  nodes = {
    ioc = {
      systemd.services.ioc = {
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];

        serviceConfig.ExecStart = "${pkgs.epnix.epics-base}/bin/softIoc -S -d ${./test.db}";
      };

      environment.systemPackages = [ pkgs.epnix.epics-base ];
      environment.epics = {
        ca_addr_list = [ "localhost" ];
        ca_auto_addr_list = false;
      };

      networking.firewall.allowedTCPPorts = [ 5064 ];
      networking.firewall.allowedUDPPorts = [ 5064 ];
    };

    server = {
      services.archiver-appliance = {
        enable = true;

        # Weird, but the broadcast address is not properly set
        settings = {
          EPICS_CA_AUTO_ADDR_LIST = false;
          # IOC is the 1st machine, sorted alphabetically
          EPICS_CA_ADDR_LIST = [ "192.168.1.1" ];
        };

        stores = {
          mts.location = "/tmp/mts";
          lts.location = "/tmp/lts";
        };
      };

      environment.epics = {
        ca_addr_list = [ "ioc" ];
        ca_auto_addr_list = false;
      };

      networking.firewall.allowedTCPPorts = [ 8080 ];
    };
  };

  testScript = builtins.readFile ./test_script.py;
}
