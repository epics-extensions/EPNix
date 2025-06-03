{pkgs, ...}: let
  inherit (pkgs) epnixLib;

  ioc = pkgs.epnix.support.callPackage ./ioc.nix {};
in {
  name = "support-pvxs-qsrv2";
  meta.maintainers = with epnixLib.maintainers; [minijackson];

  nodes = {
    client = {
      environment.systemPackages = [
        pkgs.epnix.epics-base
        pkgs.epnix.support.pvxs
      ];
      networking.firewall.allowedTCPPorts = [5075];
      networking.firewall.allowedUDPPorts = [5076];
    };
    ioc = {
      services.iocs.ioc = {
        package = ioc;
        workingDirectory = "iocBoot/iocSimple";
      };
      networking.firewall.allowedTCPPorts = [5075];
      networking.firewall.allowedUDPPorts = [5076];
    };
  };

  extraPythonPackages = p: [p.json5];
  # Type checking on extra packages doesn't work yet
  skipTypeCheck = true;

  testScript = ''
    import json5

    start_all()

    addr_list = "EPICS_PVA_ADDR_LIST=192.168.1.2"
    p = "PVXS:QSRV2:"

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
      client.wait_until_succeeds(f"{addr_list} pvget {p}ai", timeout=60)

    with subtest("Check initial data"):
      value = pvget(f"{p}ai")
      assert value["value"] == 42
      assert value["display"]["description"] == "An ai"

      value = pvget(f"{p}stringin")
      assert value["value"] == "hello"
      assert value["display"]["description"] == "An stringin"

      value = pvget(f"{p}waveform")
      assert value["value"] == ""
      assert value["display"]["description"] == "An waveform"

    with subtest("PVs can be set"):
      #pvput(f"{p}ai", "1337")
      #assert pvget("{p}ai")["value"] == 1337

      pvput(f"{p}stringin", "world")
      assert pvget(f"{p}stringin")["value"] == "world"

      pvput(f"{p}waveform", '"some long text"')
      assert pvget(f"{p}waveform")["value"] == "some long text"

    with subtest("PVXS command-line utilities work"):
      # assert pvxget(f"{p}ai") == "1337"
      assert pvxget(f"{p}ai") == "42"
      pvxput(f"{p}ai", "153")
      assert pvxget(f"{p}ai") == "153"

      pvxput(f"{p}waveform", "something")
      assert pvxget(f"{p}waveform") == '"something"'
      print(client.succeed(f"{addr_list} pvxinfo {p}waveform"))
  '';

  passthru = {
    inherit ioc;
  };
}
