{ build, pkgs, ... }:

pkgs.nixosTest {
  name = "simple";

  machine = {
    environment.systemPackages = [ pkgs.epnix.epics-base ];

    systemd.services.my-ioc = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${build}/iocBoot/iocexample/st.cmd";
        WorkingDirectory = "${build}/iocBoot/iocexample";
      };
    };
  };

  testScript = ''
    start_all()

    machine.wait_for_unit("default.target")

    machine.wait_for_unit("my-ioc.service")

    print(machine.succeed("caget stringin"))
    print(machine.succeed("caget stringout"))
    machine.fail("caget non-existing")

    machine.succeed("caput stringout 'hello'")
    assert "hello" in machine.succeed("caget stringout")
    assert "hello" not in machine.succeed("caget stringin")
  '';
}
