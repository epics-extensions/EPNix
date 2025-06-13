{
  epnixLib,
  pkgs,
  ...
}: {
  name = "ca-gateway-simple-check";
  meta.maintainers = with epnixLib.maintainers; [minijackson];

  nodes = let
    inherit (epnixLib.testing) softIoc;
  in {
    # Test two IOC on their own network, but only one in the ADDR_LIST of the gateway
    ioc = {
      imports = [
        (softIoc ''
          record(ai, "PV_CLIENT") { }
          record(ai, "PV_CLIENT_IGNORED") { }
        '')
      ];
      virtualisation.vlans = [1];
    };

    invisible_ioc = {
      imports = [
        (softIoc ''
          record(ai, "PV_INVISIBLE_CLIENT") { }
        '')
      ];
      virtualisation.vlans = [1];
    };

    # Test one IOC in its own network, but put the broadcast address
    # in the ADDR_LIST of the gateway.
    # Useful for testing the openFirewall option
    ioc_broadcast = {
      imports = [
        (softIoc ''
          record(ai, "PV_FROM_BROADCAST") { }
        '')
      ];
      virtualisation.vlans = [2];
    };

    gateway = {
      environment.systemPackages = [pkgs.epnix.epics-base];
      services.ca-gateway = {
        enable = true;
        openFirewall = true;
        settings = {
          # One unicast, one broadcast
          cip = ["ioc" "192.168.2.255"];
          pvlist = pkgs.writeText "gateway.pvlist" ''
            EVALUATION ORDER DENY, ALLOW

            .* DENY
            PV_CLIENT ALLOW
            PV_FROM_BROADCAST ALLOW
          '';
        };
      };

      # Put 3 first here so that the /etc/hosts file in VMs
      # has the gateway IP from vlan 3
      virtualisation.vlans = [3 1 2];
    };

    client = {
      environment.systemPackages = [pkgs.epnix.epics-base];
      environment.epics = {
        ca_addr_list = ["gateway"];
        ca_auto_addr_list = false;
      };
      virtualisation.vlans = [3];
    };
  };

  testScript = ''
    start_all()

    gateway.wait_for_unit("ca-gateway.service")
    ioc.wait_for_unit("ioc.service")
    invisible_ioc.wait_for_unit("ioc.service")
    client.wait_for_unit("multi-user.target")

    client.wait_until_succeeds("caget PV_CLIENT")
    client.wait_until_succeeds("caget PV_FROM_BROADCAST")
    client.fail("caget PV_INVISIBLE_CLIENT")
    client.fail("caget PV_CLIENT_IGNORED")
  '';
}
