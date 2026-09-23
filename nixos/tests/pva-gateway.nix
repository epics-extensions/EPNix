{
  epnixLib,
  pkgs,
  ...
}:
{
  name = "pva-gateway-simple-check";
  meta.maintainers = with epnixLib.maintainers; [ minijackson ];

  nodes = {
    # Test two IOC on their own network, but only one in the ADDR_LIST of the gateway
    ioc = {
      services.softIocs.ioc = {
        dbText = ''
          record(ai, "PV_CLIENT") { }
          record(ai, "PV_CLIENT_IGNORED") { }
        '';
        pvAccess.enable = true;
      };
      environment.epics.openPVAFirewall = true;
      virtualisation.vlans = [ 1 ];
    };

    invisible_ioc = {
      services.softIocs.ioc = {
        dbText = ''
          record(ai, "PV_INVISIBLE_CLIENT") { }
        '';
        pvAccess.enable = true;
      };
      environment.epics.openPVAFirewall = true;
      virtualisation.vlans = [ 1 ];
    };

    # Test one IOC in its own network, but put the broadcast address
    # in the ADDR_LIST of the gateway.
    # Useful for testing the openFirewall option
    ioc_broadcast = {
      services.softIocs.ioc = {
        dbText = ''
          record(ai, "PV_FROM_BROADCAST") { }
        '';
        pvAccess.enable = true;
      };
      environment.epics.openPVAFirewall = true;
      virtualisation.vlans = [ 2 ];
    };

    gateway = {
      environment.systemPackages = [ pkgs.epnix.epics-base ];
      services.pva-gateway = {
        enable = true;
        settings = {
          clients = [
            {
              name = "clientUnicast";
              addrlist = [ "ioc" ];
            }
            {
              name = "clientBroadcast";
              addrlist = [ "192.168.2.255" ];
            }
          ];
          servers = [
            {
              name = "server4Unicast";
              clients = [ "clientUnicast" ];
              interface = [ "192.168.3.3" ];
              pvlist = pkgs.writeText "gateway.pvlist" ''
                # DENY, ALLOW not currently supported
                EVALUATION ORDER ALLOW, DENY

                .* ALLOW
                .*IGNORED.* DENY
              '';
            }
            {
              name = "server4Broadcast";
              clients = [ "clientBroadcast" ];
              interface = [ "192.168.4.3" ];
              statusprefix = "MY:GW:ST:";
            }
          ];
        };
      };

      environment.epics.openPVAFirewall = true;
      environment.epics.allowPVABroadcastDiscovery = true;

      virtualisation.vlans = [
        1
        2
        3
        4
      ];
    };

    client1 = {
      environment.systemPackages = [ pkgs.epnix.epics-base ];
      environment.epics = {
        pva_addr_list = [ "192.168.3.3" ];
        pva_auto_addr_list = false;
      };
      virtualisation.vlans = [ 3 ];
    };

    client2 = {
      environment.systemPackages = [ pkgs.epnix.epics-base ];
      environment.epics = {
        pva_addr_list = [ "192.168.4.3" ];
        pva_auto_addr_list = false;
      };
      virtualisation.vlans = [ 4 ];
    };
  };

  testScript = ''
    start_all()

    gateway.wait_for_unit("pva-gateway.service")
    ioc.wait_for_unit("ioc.service")
    invisible_ioc.wait_for_unit("ioc.service")
    client1.wait_for_unit("multi-user.target")
    client2.wait_for_unit("multi-user.target")

    client1.wait_until_succeeds("pvget PV_CLIENT")
    client2.wait_until_succeeds("pvget PV_FROM_BROADCAST")

    client1.fail("pvget PV_INVISIBLE_CLIENT")
    client1.fail("pvget PV_CLIENT_IGNORED")
    client1.fail("pvget PV_FROM_BROADCAST")

    client2.fail("pvget PV_CLIENT")
    client2.fail("pvget PV_INVISIBLE_CLIENT")
    client2.fail("pvget PV_CLIENT_IGNORED")

    for pv in [
        "clients",
        "cache",
        "refs",
        "threads",
        "ds:byhost:rx",
        "ds:byhost:tx",
        "ds:bypv:rx",
        "ds:bypv:tx",
        "us:byhost:rx",
        "us:byhost:tx",
        "us:bypv:rx",
        "us:bypv:tx",
    ]:
        print(client2.wait_until_succeeds(f"pvget MY:GW:ST:{pv}"))

    client1.fail("pvget MY:GW:ST:clients")
  '';
}
