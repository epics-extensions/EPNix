{
  epnixLib,
  pkgs,
  ...
}:
{
  name = "firewall-epics-check";

  nodes =
    let
      # Don't use the EPNix testing lib to remove the firewall configuration
      softIoc = db: {

        systemd.services.ioc = {
          wantedBy = [ "multi-user.target" ];
          wants = [ "network-online.target" ];
          after = [ "network-online.target" ];

          serviceConfig = {
            ExecStart = "${pkgs.epnix.epics-base}/bin/softIoc -S -d ${pkgs.writeText "softIoc.db" db}";
            DynamicUser = true;
          };
        };
        environment.systemPackages = [ pkgs.epnix.epics-base ];
      };
      softIocPVA = dbPVA: {

        systemd.services.ioc = {
          wantedBy = [ "multi-user.target" ];
          wants = [ "network-online.target" ];
          after = [ "network-online.target" ];

          serviceConfig = {
            ExecStart = "${pkgs.epnix.support.pvxs}/bin/softIocPVX -S -d ${pkgs.writeText "softIocPVA.db" dbPVA}";
            DynamicUser = true;
          };
        };
        environment.systemPackages = [ pkgs.epnix.epics-base ];
      };

    in
    {
      iocCAOpen = {
        networking.firewall.enable = true;

        environment.epics.openCAFirewall = true;
        imports = [
          (softIoc ''
            record(ai, "TEST_FW_TRUE") {}
          '')
        ];
      };
      iocCAClose = {

        networking.firewall.enable = true;

        environment.epics.openCAFirewall = false;
        imports = [
          (softIoc ''
            record(ai, "TEST_FW_FALSE") {}
          '')
        ];
      };

      iocCADiscover = {
        networking.firewall.enable = true;

        environment.epics.openCAFirewall = true;
        imports = [
          (softIoc ''
            record(ai, "TEST_FW_DISCOVER") {}
          '')
        ];
      };
      iocPVAOpen = {
        networking.firewall.enable = true;
        environment.epics.openPVAFirewall = true;
        imports = [
          (softIocPVA ''
            record(ai, "TEST_FW_TRUE") {}
          '')
        ];
      };
      iocPVAClose = {
        networking.firewall.enable = true;
        environment.epics.openPVAFirewall = false;
        imports = [
          (softIocPVA ''
            record(ai, "TEST_FW_FALSE") {}
          '')
        ];
      };
      iocPVADiscover = {
        networking.firewall.enable = true;
        environment.epics.openPVAFirewall = true;
        imports = [
          (softIocPVA ''
            record(ai, "TEST_FW_DISCOVER") {}
          '')
        ];
      };
      clientCAWithoutAutoAddr = {
        networking.firewall.enable = true;
        environment = {
          epics = {
            ca_auto_addr_list = false;
            ca_addr_list = [
              "iocCAOpen"
              "iocCAClose"
            ];
          };
          systemPackages = [
            pkgs.epnix.epics-base
          ];
        };
      };
      clientCAWithAutoAddr = {
        networking.firewall.enable = true;
        environment = {
          epics = {
            ca_addr_list = [ "192.168.1.255" ];
            allowCABroadcastDiscovery = true;
          };

          systemPackages = [ pkgs.epnix.epics-base ];
        };
      };
      clientPVAWithAutoAddr = {
        networking.firewall.enable = true;
        environment = {
          systemPackages = [
            pkgs.epnix.epics-base
          ];
          variables = {
            EPICS_PVA_ADDR_LIST = "192.168.1.255";
          };
          epics.allowPVABroadcastDiscovery = true;

        };
      };
      clientPVAWithoutAutoAddr = {
        networking.firewall.enable = true;
        environment = {
          systemPackages = [
            pkgs.epnix.epics-base
          ];
          variables = {
            EPICS_PVA_ADDR_LIST = "iocPVAOpen";
            EPICS_PVA_AUTO_ADDR_LIST = "NO";
          };
        };
      };
    };

  testScript = ''
    start_all()

    iocCAOpen.wait_for_unit("ioc.service")
    iocCAClose.wait_for_unit("ioc.service")
    iocCADiscover.wait_for_unit("ioc.service")
    iocPVAClose.wait_for_unit("ioc.service")
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
