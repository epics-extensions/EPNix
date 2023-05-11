# EPNix

![](./doc/logo.svg)

EPNix (pronunciation: like you are high on mushrooms) packages EPICS-related software using the [Nix] package manager.

It's made of three parts:

-   the EPICS IOC framework
-   other EPICS-related packages
-   NixOS modules

The EPICS IOC framework lets you package, deploy, and test EPICS IOCs using the Nix package manager, which provides several benefits.
For more information, see the [EPICS IOCs introduction].

EPNix also packages other EPICS-related tools, like procServ, Phoebus, etc.
You can build them using Nix, and in the future download them pre-compiled, while having a strong guarantee that they will work as-is.
For a list of all supported EPICS-related packages, see the [Packages list].

EPNix also provides NixOS modules, which are instructions on how to configure various EPICS-related services on NixOS machines (for example the Phoebus alarm server).
EPNix strives to have integration tests for each of those module.
For more information, see the [NixOS modules introduction].

  [Nix]: https://nixos.org/guides/how-nix-works.html
  [EPICS IOCs introduction]: https://epics-extensions.github.io/EPNix/ioc/introduction.html
  [Packages list]: https://epics-extensions.github.io/EPNix/pkgs/packages.html
  [NixOS modules introduction]: https://epics-extensions.github.io/EPNix/nixos/introduction.html

## Getting started building IOCs

See [over there] in the documentation book.

  [over there]: https://epics-extensions.github.io/EPNix/ioc/getting-started.html

## Packaging policy

As EPNix provides a package repository, packaging for example `epics-base`, `asyn`, `StreamDevice`, `procServ`, `phoebus`, etc., it needs to have a packaging policy.

In its package repository, EPNix officially supports the latest upstream version.

However, since EPNix is a git repository, you will be able, through Nix, to use a fixed version of EPNix, without being forced to upgrade your dependencies.

### The epics-base package

The epics-base package has no significant modification compared to the upstream version at [Launchpad].
One goal of EPNix is to keep those modifications to a minimum, and upstream what's possible.

  [Launchpad]: https://git.launchpad.net/epics-base

## Quick example of an EPNix configuration

``` nix
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

  # You can specify environment variables for your development shell like this:
  # ---
  devShell.environment.variables."EPICS_CA_ADDR_LIST" = "localhost";
};
```
