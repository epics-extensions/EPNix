{ pkgs, ... }:
{
  name = "firewall-epics-check";

  nodes = {
    iocCAOpen = {
      environment.epics.openCAFirewall = true;
      services.softIocs.ioc.dbText = ''record(ai, "TEST_FW_TRUE") {}'';
      environment.systemPackages = [ pkgs.epnix.epics-base ];
    };

    iocCAClosed = {
      environment.epics.openCAFirewall = false;
      services.softIocs.ioc.dbText = ''record(ai, "TEST_FW_FALSE") {}'';
      environment.systemPackages = [ pkgs.epnix.epics-base ];
    };

    iocCADiscover = {
      environment.epics.openCAFirewall = true;
      services.softIocs.ioc.dbText = ''record(ai, "TEST_FW_DISCOVER") {}'';
      environment.systemPackages = [ pkgs.epnix.epics-base ];
    };

    iocPVAOpen = {
      environment.epics.openPVAFirewall = true;
      services.softIocs.ioc = {
        dbText = ''record(ai, "TEST_FW_TRUE") {}'';
        pvAccess.enable = true;
      };
      environment.systemPackages = [ pkgs.epnix.epics-base ];
    };

    iocPVAClosed = {
      environment.epics.openPVAFirewall = false;
      services.softIocs.ioc = {
        dbText = ''record(ai, "TEST_FW_FALSE") {}'';
        pvAccess.enable = true;
      };
      environment.systemPackages = [ pkgs.epnix.epics-base ];
    };

    iocPVADiscover = {
      environment.epics.openPVAFirewall = true;
      services.softIocs.ioc = {
        dbText = ''record(ai, "TEST_FW_DISCOVER") {}'';
        pvAccess.enable = true;
      };
      environment.systemPackages = [ pkgs.epnix.epics-base ];
    };

    clientCAWithoutAutoAddr = {
      environment = {
        epics = {
          ca_auto_addr_list = false;
          ca_addr_list = [
            "iocCAOpen"
            "iocCAClosed"
          ];
        };
        systemPackages = [ pkgs.epnix.epics-base ];
      };
    };

    clientCAWithAutoAddr = {
      environment = {
        epics = {
          ca_addr_list = [ "192.168.1.255" ];
          allowCABroadcastDiscovery = true;
        };
        systemPackages = [ pkgs.epnix.epics-base ];
      };
    };

    clientPVAWithAutoAddr = {
      environment = {
        systemPackages = [ pkgs.epnix.epics-base ];
        epics = {
          pva_addr_list = [ "192.168.1.255" ];
          allowPVABroadcastDiscovery = true;
        };
      };
    };

    clientPVAWithoutAutoAddr = {
      environment = {
        systemPackages = [ pkgs.epnix.epics-base ];
        epics = {
          pva_addr_list = [ "iocPVAOpen" ];
          pva_auto_addr_list = false;
        };
      };
    };
  };

  testScript = ''
    start_all()

    iocCAOpen.wait_for_unit("ioc.service")
    iocCAClosed.wait_for_unit("ioc.service")
    iocCADiscover.wait_for_unit("ioc.service")
    iocPVAClosed.wait_for_unit("ioc.service")
    iocPVAOpen.wait_for_unit("ioc.service")
    clientCAWithoutAutoAddr.wait_for_unit("multi-user.target")
    clientCAWithAutoAddr.wait_for_unit("multi-user.target")
    clientPVAWithoutAutoAddr.wait_for_unit("multi-user.target")
    clientPVAWithAutoAddr.wait_for_unit("multi-user.target")

    # Test CA without autodiscovery
    clientCAWithoutAutoAddr.wait_until_succeeds("caget TEST_FW_TRUE")
    clientCAWithoutAutoAddr.fail("caget TEST_FW_FALSE")
    # Test CA with autodiscovery
    clientCAWithoutAutoAddr.fail("caget TEST_FW_DISCOVER")
    clientCAWithAutoAddr.wait_until_succeeds("caget TEST_FW_DISCOVER")
    # PVA test without autodiscovery
    clientPVAWithoutAutoAddr.wait_until_succeeds("pvget TEST_FW_TRUE")
    clientPVAWithoutAutoAddr.fail("pvget TEST_FW_FALSE")
    # PVA test without autodiscovery
    clientPVAWithAutoAddr.wait_until_succeeds("pvget TEST_FW_DISCOVER")
    clientPVAWithoutAutoAddr.fail("pvget TEST_FW_DISCOVER")
  '';

}
