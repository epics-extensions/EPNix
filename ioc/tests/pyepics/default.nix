{pkgs, ...}: let
  inherit (pkgs) epnixLib lib;
in {
  name = "pytest";
  meta.maintainers = with epnixLib.maintainers; [minijackson];

  extraPythonPackages = p: [p.pyepics];
  skipTypeCheck = true;

  nodes.ioc = {
    imports = [
      (epnixLib.testing.softIoc ''
        record(ai, "AI") { }
        record(stringout, "STRINGOUT") { }
      '')
    ];
  };

  testScript = let
    python = lib.getExe (pkgs.python3.withPackages (p: [p.pyepics]));
    iocTestScript = pkgs.writeText "iocTestScript.py" ''
      import os

      import epics

      os.environ["EPICS_CA_AUTO_ADDR_LIST"] = "NO"
      os.environ["EPICS_CA_ADDR_LIST"] = "localhost"

      stringout = epics.PV("STRINGOUT")

      assert epics.caget("AI") == 0
      assert stringout.get() == ""

      assert epics.caput("AI", 42.0, wait=True) == 1
      assert stringout.put("hello", wait=True) == 1

      assert epics.caget("AI") == 42
      assert stringout.get() == "hello"
    '';
  in ''
    start_all()
    ioc.wait_for_unit("ioc.service")

    print(ioc.succeed("${python} ${iocTestScript}"))
  '';
}
