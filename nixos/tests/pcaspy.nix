{
  epnixLib,
  pkgs,
  lib,
  ...
}:
{
  name = "pcaspy";
  meta.maintainers = with epnixLib.maintainers; [ minijackson ];

  nodes = {
    client = {
      environment.systemPackages = [ pkgs.epnix.epics-base ];
      environment.epics = {
        ca_addr_list = [ "server" ];
        ca_auto_addr_list = false;
        allowCABroadcastDiscovery = true;
      };
    };

    server = {
      environment.epics.openCAFirewall = true;

      systemd.services.pcaspy-server = {
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        serviceConfig.ExecStart =
          pkgs.writers.writePython3 "pcaspy-server" { libraries = [ pkgs.python3Packages.pcaspy ]; }
            ''
              # Script taken from:
              # https://github.com/paulscherrerinstitute/pcaspy/blob/59157d51f1913491f85d59b3141cf97116015822/example/dynamic_pv.py

              from pcaspy import Driver, SimpleServer
              import pcaspy.cas as cas

              import re

              prefix = "MTEST:"
              pvdb = {"STATIC": {}}

              # keep reference to dynamic spectra pvs
              spvs = {}


              class SpectrumPV(cas.casPV):
                  def __init__(self, name):
                      cas.casPV.__init__(self)
                      self.name = name
                      self.index = int(re.match(r"MTEST:SPECTRUM(\d+)", name).group(1))

                  def getValue(self, value):
                      value.put([self.index] * 100)
                      return cas.S_casApp_success

                  def maxDimension(self):
                      return 1

                  def maxBound(self, dims):
                      return 100


              # The driver serves normal static PVs
              class MyDriver(Driver):
                  def __init__(self):
                      Driver.__init__(self)


              class MyServer(SimpleServer):
                  def pvExistTest(self, context, addr, fullname):
                      if fullname.startswith("MTEST:SPECTRUM"):
                          return cas.pverExistsHere
                      else:
                          return SimpleServer.pvExistTest(self, context, addr, fullname)

                  def pvAttach(self, context, fullname):
                      if fullname.startswith("MTEST:SPECTRUM"):
                          if fullname not in spvs:
                              pv = SpectrumPV(fullname)
                              spvs[fullname] = pv
                          return spvs[fullname]
                      else:
                          return SimpleServer.pvAttach(self, context, fullname)


              if __name__ == "__main__":
                  server = MyServer()
                  server.createPV(prefix, pvdb)
                  driver = MyDriver()

                  while True:
                      server.process(1)
            '';
      };
    };
  };

  testScript = ''
    start_all()

    server.wait_for_unit("pcaspy-server.service")

    print(client.wait_until_succeeds("caget MTEST:STATIC"))
    print(client.succeed("caput MTEST:STATIC 42 && caget -t MTEST:STATIC | grep -qxF 42"))
    print(client.succeed("caget MTEST:SPECTRUM{1,2,3}"))
  '';
}
