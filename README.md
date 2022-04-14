# EPNix

EPNix (pronunciation: like you are high on mushrooms) is a way of building and
packaging EPICS IOCs using the [Nix] package manager.

By leveraging the Nix package manager, it provides several advantages compared
to packaging EPICS the traditional way:

- Reproducibility: your development environment is the same as your coworker's
  development environment, which is the same as your production
  environment.

- Complete dependencies: your EPICS IOCs ship with the complete set of
  dependencies, allowing you to deploy your IOC without needing to install any
  dependency on the target machine (except for Nix itself).

- Dependency traceability: the version of your dependencies are locked, updated
  manually, and traced in your `flake.lock` file. Combined with code
  versioning, this allows your project to build with the same environment years
  later, and allows you to rollback if one of your dependency becomes
  incompatible.

- Development shell: provides you with a set of tool adapted to your project,
  no matter what you have installed on your machine.

- Declarative configuration: define what you want in your IOC in a declarative
  and extensible manner.

- Functional tests: Run automated isolated tests inside a defined virtual
  machine.

[Nix]: <https://nixos.org/guides/how-nix-works.html>

## Getting started

The guide to getting started is [over there](./doc/src/getting-started.md) in
the documentation book.

## Quick example of a configuration file

```nix
epnix = {
  meta.name = "my-top";

  # You can choose the version of EPICS-base here:
  # ---
  epics-base.releaseBranch = "3"; # Defaults to "7"

  # Add one of the supported modules here:
  # ---
  support.modules = with pkgs.epnix.support; [ StreamDevice ];

  # Add your applications:
  # ---
  applications.apps = [ "inputs.myExampleApp" ];

  # And your iocBoot directories:
  # ---
  boot.iocBoots = [ ./iocBoot/iocmyProject ];

  # You can specify environment variables in your development shell like this:
  # ---
  devShell.environment.variables."EPICS_CA_ADDR_LIST" = "localhost";
};
```
