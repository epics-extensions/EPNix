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
      services.softIocs.ioc.dbFiles = [ ./test.db ];
      environment.systemPackages = [ pkgs.epnix.epics-base ];
      environment.epics = {
        ca_addr_list = [ "localhost" ];
        ca_auto_addr_list = false;
        openCAFirewall = true;
      };
    };

    server = {
      services.archiver-appliance = {
        enable = true;

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

      virtualisation.diskSize = 2048;
    };
  };

  testScript = builtins.readFile ./test_script.py;
}
