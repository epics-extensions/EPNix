# Packaging Python scripts

As EPNix uses Nix, you can packaging Python scripts as helpers for your
integration tests, by using the provided [infrastructure] of nixpkgs. As
a matter of fact, you can package any program in any language, but we
recommend using Python scripts with [Poetry] for their simplicity and
popularity.

[infrastructure]: <https://nixos.org/manual/nixpkgs/stable/#python>
[Poetry]: <https://python-poetry.org/>

## Getting started

We recommend using the Poetry package in your EPNix environment, through Nix,
to use the same version as the one building the Python script.

You can do this by adding this bit in your `flake.nix` file:

```nix
epnix.devShell.packages = [
  { package = pkg.poetry; category = "development tools"; }
];
```

Next, you can start your development shell with `nix develop`, go to the
directory of your test, and create a new project with the command:

```bash
poetry new <my-python-script>
```

This will create a Python project under the `<my-python-script>` directory.
Under it, you will find a `pyproject.toml` where you can specify the
dependencies of your script. For example, you can specify `modbus` to add the
Python [modbus package], if you want to test modbus communication. You can
remove the dependency on pytest if won't add unit tests to your Python script.

[modbus package]: <https://pypi.org/project/modbus/>

To add an entry point to your Python code, you can use the
`tool.poetry.scripts` section like so:

```toml
[tool.poetry.scripts]
my_python_script = "my_python_script:main"
```

This will add an executable named `my_python_script` that will run the `main`
function of the `my_python_script` module.

For more information on how to use poetry, please refer to the [Poetry
documentation].

[Poetry documentation]: <https://python-poetry.org/docs/basic-usage/>

Before packaging this script using Nix, it's important to generate the lock
file, and to remember to re-generate it each time you change the
`pyproject.toml` file.

You can do this with the following command:

```bash
poetry lock
```

Then, in your [integration test] file, you can package it like this:

[integration test]: ./integration-tests.md

```nix
{ build, pkgs, ... }:

let
  pythonScript = pkgs.poetry2nix.mkPoetryApplication {
    projectDir = ./path/to/my-python-script;
  };
in
pkgs.nixosTest {
  name = "myTest";

  # ...
}
```

With this, you can use the `pythonScript` variable as you see fit.

## Example usage: As a one shot test script

Using a packaged Python script instead of the provided `testScript` has several
advantages. It can use dependencies provided by the community (like `modbus`,
`systemd`, etc.), and you can make it run on the running virtual machine.

Python script:

```python
import subprocess

from modbus.client import *


def main():
    c = client(host='HOSTNAME')
    modbus_values = c.read(FC=3, ADR=10, LEN=8)

    for i in range(8):
        epics_value = subprocess.run(
            ["caget", "-t", "MyPV:" + i],
            capture_output=True,
        ).stdout.strip()

        assert modbus_values[i] == int(epics_value), "Wrong value provided by epics"
```

Nix test:

```nix
{ build, pkgs, ... }:

let
  pythonScript = pkgs.poetry2nix.mkPoetryApplication {
    projectDir = ./path/to/my-python-script;
  };
in
pkgs.nixosTest {
  name = "myTest";

  machine = {
    environment.systemPackages = [ pythonScript ];

    # ...
  };

  testScript = ''
    # ...

    my_python_script --my-flag --my-option=3

    # ...
  '';
}
```

## Example usage: As a systemd service

Using a Python script as a systemd service is useful for mocking devices. For
more information, please see the [Creating a mocking server] guide.

[Creating a mocking server]: ./creating-a-mock-server.md

Python script:

```python
import logging
from logging import info


def main():
    logging.basicConfig(level=logging.INFO)

    while True:
        info("doing things")

        # ...
```

Nix test:

```nix
{ build, pkgs, ... }:

let
  pythonScript = pkgs.poetry2nix.mkPoetryApplication {
    projectDir = ./path/to/my-python-script;
  };
in
pkgs.nixosTest {
  name = "myTest";

  machine = {
    systemd.services."my-python-service" = {
      wantedBy = [ "multi-user.target" ];

      serviceConfig.ExecStart = "${pythonScript}/bin/my_python_script";
    };

    # ...
  };

  testScript = ''
    # ...

    machine.wait_for_unit("my-python-service.service")

    # ...
  '';
}
```
