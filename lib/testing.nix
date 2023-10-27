{
  # Takes the content of an EPICS db file (db).
  # Outputs a NixOS configuration that starts a soft ioc systemd service.
  #
  # Usage example:
  #
  #     {
  #       imports = [
  #         (softIoc ''
  #           record(ai, "EXAMPLE_PV") { }
  #         '')
  #       ];
  #       virtualisation.vlans = [1];
  #     }
  softIoc = db: {pkgs, ...}: let
    dbfile = pkgs.writeText "softIoc.db" db;
  in {
    systemd.services.ioc = {
      wantedBy = ["multi-user.target"];
      wants = ["network-online.target"];
      after = ["network-online.target"];

      serviceConfig = {
        ExecStart = "${pkgs.epnix.epics-base}/bin/softIoc -S -d ${dbfile}";
        DynamicUser = true;
      };
    };
    environment.systemPackages = [pkgs.epnix.epics-base];

    networking.firewall.allowedTCPPorts = [5064 5065];
    networking.firewall.allowedUDPPorts = [5064 5065];
  };
}
