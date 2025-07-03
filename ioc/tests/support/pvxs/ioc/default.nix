{ pkgs, ... }:
let
  inherit (pkgs) epnixLib;

  ioc = pkgs.epnix.support.callPackage ./ioc.nix { };
in
{
  name = "support-pvxs-ioc";
  meta.maintainers = with epnixLib.maintainers; [ minijackson ];

  nodes = {
    client = {
      environment.systemPackages = [
        pkgs.epnix.epics-base
        pkgs.epnix.support.pvxs
      ];
      networking.firewall.allowedTCPPorts = [ 5075 ];
      networking.firewall.allowedUDPPorts = [ 5076 ];
    };
    ioc = {
      services.iocs.ioc = {
        package = ioc;
        workingDirectory = "iocBoot/iocSimple";
      };
      networking.firewall.allowedTCPPorts = [ 5075 ];
      networking.firewall.allowedUDPPorts = [ 5076 ];
    };
  };

  extraPythonPackages = p: [ p.json5 ];
  # Type checking on extra packages doesn't work yet
  skipTypeCheck = true;

  testScript = ''
    import json5

    start_all()

    addr_list = "EPICS_PVA_ADDR_LIST=192.168.1.2"

    def pvget(name: str):
      return json5.loads(client.succeed(f"{addr_list} pvget {name} -M json | cut -d' ' -f2-"))

    def pvxget(name: str):
      output = client.succeed(f"{addr_list} pvxget {name}")
      return output.splitlines()[1].split()[-1]

    def _pvput(utility: str, name: str, value: str):
      client.succeed(f"{addr_list} {utility} {name} {value}")

    def pvput(name: str, value: str):
      _pvput("pvput", name, value)

    def pvxput(name: str, value: str):
      _pvput("pvxput", name, value)

    with subtest("wait until IOC starts"):
      ioc.wait_for_unit("ioc.service")
      client.wait_until_succeeds(f"{addr_list} pvget my:pv:name", timeout=60)

    with subtest("PV has the correct value"):
      value = pvget("my:pv:name")
      assert value["value"] == 42
      assert value["display"]["description"] == "My PV description"

    with subtest("PV can be set"):
      pvput("my:pv:name", "1337")
      assert pvget("my:pv:name")["value"] == 1337

    with subtest("PVXS command-line utilities work"):
      assert pvxget("my:pv:name") == "1337"
      pvxput("my:pv:name", "42")
      assert pvxget("my:pv:name") == "42"
      client.succeed(f"{addr_list} pvxinfo my:pv:name")
  '';

  passthru = {
    inherit ioc;
  };
}
