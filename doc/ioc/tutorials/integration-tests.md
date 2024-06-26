---
title: Integration tests
---

# Writing the test

Through the [NixOS testing framework], EPNix provides a way of specifying a machine configuration, and running a Python script that can do various kind of testing.

If you created your IOC using the EPNix template, like suggested in the [StreamDevice tutorial], you will see a `checks/` directory.
This directory should contain the integration tests you want to run.

To add an integration test to EPNix, record it in your `flake.nix` under the `epnix.checks.files` option.

For example, in the EPNix template, you will see in your `flake.nix` file:

``` nix
checks.files = [ ./checks/simple.nix ];
```

The `./checks/<myTest>.nix` file should contain a NixOS test like so:

``` nix
{ build, pkgs, ... }:

pkgs.nixosTest {
  name = "myTest";

  machine = {
    # Description of the NixOS machine...
  };

  testScript = ''
    # Python script that does the testing...
  '';
}
```

This test will create a NixOS virtual machine from the given configuration, and run the test script.
Note that the test script does *not* run on the virtual machine, but communicates with it.
This is because the test script can start, shut down, or reboot the machine, and also because NixOS tests can also manage several virtual machines, not just one.

For an overview of what you can input in the machine configuration, please refer to the [NixOS documentation].
You can also read about the Python test script API [here][NixOS testing framework].

  [NixOS testing framework]: https://nixos.org/manual/nixos/stable/index.html#sec-nixos-tests
  [StreamDevice tutorial]: ./streamdevice.md
  [NixOS documentation]: https://nixos.org/manual/nixos/stable/index.html#sec-configuration-syntax

# Starting your IOC through systemd

We recommend starting your IOC through a systemd service, which you can describe in Nix like so:

<!-- TODO: change that -->

``` nix
# Inside the `machine` attribute
{
  systemd.services.my-ioc = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${build}/iocBoot/iocexample/st.cmd";
      WorkingDirectory = "${build}/iocBoot/iocexample";

      # Makes the EPICS command-line not quit for 100 seconds, if it doesn't
      # receive anything on the standard input
      StandardInputText = "epicsThreadSleep(100)";
    };
  };

  # Provides the caget / caput / etc. commands to the test script
  environment.systemPackages = [ pkgs.epnix.epics-base ];
}
```

You can view the list of options available for a NixOS machine [here].

Then, you can write your test script.
Note that the test script doesn't run directly on the machine, but communicates with the machine through the `machine` variable.

An example of a testing script:

``` python
start_all()

machine.wait_for_unit("default.target")
machine.wait_for_unit("my-ioc.service")

machine.wait_until_succeeds("caget stringin")
machine.wait_until_succeeds("caget stringout")
machine.fail("caget non-existing")

with subtest("testing stringout"):
    def test_stringout(_) -> bool:
        machine.succeed("caput stringout 'hello'")
        status, _output = machine.execute("caget -t stringout | grep -qxF 'hello'")

        return status == 0

    retry(test_stringout)

    assert "hello" not in machine.succeed("caget -t stringin")
```

Note that the script extensively uses the `wait_until_succeeds` method and the `retry` function.
This is because EPICS has few guarantees about whether it propagates changes immediately, and so it's better to encourage the use of retries, instead of hoping the timing lines up.

If you would like to use a fully fledged python script on the machine, which can use Python dependencies like pyepics, please refer to the guide [Packaging Python scripts].

You can find methods available on the `machine` variable and other particularities in the [NixOS tests documentation].

You can also look at examples either in the EPNix repository under the [`checks` folder], or in nixpkgs under the [`nixos/tests` folder].

```{=html}
<!-- TODO: this doesn't explain how to run the test -->
```

  [here]: https://search.nixos.org/options?channel=21.11&from=0&size=50&sort=alpha_asc&type=packages&query=systemd.services.
  [Packaging Python scripts]: ../guides/testing/packaging-python-scripts.md
  [NixOS tests documentation]: https://nixos.org/manual/nixos/stable/index.html#sec-nixos-tests
  [`checks` folder]: https://github.com/epics-extensions/epnix/tree/master/checks
  [`nixos/tests` folder]: https://github.com/NixOS/nixpkgs/tree/master/nixos/tests
